//
//  GroupVolunteerTableViewCell.swift
//  Eia
//
//  Created by Cleofas Pereira on 20/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class GroupVolunteerTableViewCell: UITableViewCell {
    private let fbDbRef = Database.database().reference()
    private let container = AppDelegate.persistentContainer!
    private let workingIndicator = WorkingIndicator()

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
        photoImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    public func setup(withVolunteer volunteer: Voluntary) {
        nameLabel.text = volunteer.name
        if let photoStr = volunteer.photo_str, let photoData = Data(base64Encoded: photoStr), let photoImage = UIImage(data: photoData) {
            photoImageView.image = photoImage
        } else {
            photoImageView.image = nil
            let defaultPhoto = UIImage(named: "voluntary_default_icon")
            photoImageView.image = defaultPhoto
        }
    }
    public func setup(withVolunteerItem volunteerItem: Voluntary_Item) {
        let context = container.viewContext
        let volunteerItemId = volunteerItem.identifier ?? ""
        nameLabel.text = volunteerItem.name
        if let volunteer = Voluntary.find(matching: volunteerItemId, in: context) {
            setup(withVolunteer: volunteer)
        }
        updateVoluntaryFromCloud(withVoluntaryItem: volunteerItem)
    }
    
    private func updateVoluntaryFromCloud(withVoluntaryItem voluntaryItem: Voluntary_Item) {
        let context = container.viewContext
        let identifier = voluntaryItem.identifier ?? ""
        workingIndicator.show(at: self.contentView)
        fbDbRef.child(Voluntary.rootFirebaseDatabaseReference).child(identifier).observeSingleEvent(of: .value, with: {[weak self](snapshot) in
            if let voluntaryDic = snapshot.value as? NSDictionary {
                if let voluntary = Voluntary.createOrUpdate(matchDictionary: voluntaryDic, in: context) {
                    DispatchQueue.main.async {[weak self] in
                        
                        self?.setup(withVolunteer: voluntary)
                    }
                }
            }
            self?.workingIndicator.hide()
        })
    }

}

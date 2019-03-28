//
//  GroupTableViewCell.swift
//  Eia
//
//  Created by Cleofas Pereira on 05/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class GroupTableViewCell: UITableViewCell {
    private let container: NSPersistentContainer = AppDelegate.persistentContainer!
    private let fbDbRef = Database.database().reference()
    private var workingIndicator = WorkingIndicator()
    public var group: Group?
    
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        groupImageView.layer.cornerRadius = groupImageView.frame.height / 2
        groupImageView.clipsToBounds = true
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    public func setup(with group: Group) {
        groupNameLabel.text = group.name
        groupDescriptionLabel.text = group.group_description
        if let photoStr = group.photo_str, let photoData = Data(base64Encoded: photoStr), let photoImage = UIImage(data: photoData) {
            groupImageView.image = photoImage
        } else {
            groupImageView.image = nil
            let defaultPhoto = UIImage(named: "group_default_icon")
            groupImageView.image = defaultPhoto
        }
    }
    public func setup(withGroupItem groupItem: Group_Item) {
        let context = container.viewContext
        groupNameLabel.text = groupItem.name
        let identifier = groupItem.identifier ?? ""
        if let group = Group.find(matching: identifier, in: context) {
            setup(with: group)
        }
        updateGroupFromCloud(withGroupItem: groupItem)
    }
    
    private func updateGroupFromCloud(withGroupItem groupItem: Group_Item) {
        let context = container.viewContext
        let identifier = groupItem.identifier ?? ""
        workingIndicator.show(at: self.contentView)
        fbDbRef.child(Group.rootFirebaseDatabaseReference).child(identifier).observeSingleEvent(of: .value, with: {[weak self](snapshot) in
            if let groupDic = snapshot.value as? NSDictionary {
                DispatchQueue.main.async {[weak self] in
                    self?.group = Group.createOrUpdate(matchDictionary: groupDic, in: context)
                    if let group = self?.group {
                        try? context.save()
                        self?.setup(with: group)
                    }
                }
            }
            self?.workingIndicator.hide()
        })
    }
}

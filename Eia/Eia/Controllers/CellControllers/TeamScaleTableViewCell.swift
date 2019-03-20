//
//  TeamScaleTableViewCell.swift
//  Eia
//
//  Created by Cleofas Pereira on 10/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import CoreData
import FirebaseCore
import FirebaseDatabase

class TeamScaleTableViewCell: UITableViewCell {
    public var scale: Scale?
    
    private let fbDbRef = Database.database().reference()
    private let container = AppDelegate.persistentContainer!
    private let workingIndicator = WorkingIndicator()
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startHourLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endHourLabel: UILabel!
    @IBOutlet weak var scaleStatusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    private func setup(withScale scale: Scale) {
        self.scale = scale
        startDateLabel.text = scale.start?.dateStringValue
        startHourLabel.text = scale.start?.hourStringValue
        endDateLabel.text = scale.end?.dateStringValue
        endHourLabel.text = scale.end?.hourStringValue
        scaleStatusLabel.text = scale.status
    }
    public func setup(withScaleItem scaleItem: Scale_Item) {
        let context = container.viewContext
        let scaleId = scaleItem.identifier ?? ""
        if let scale = Scale.find(matching: scaleId, in: context) {
            setup(withScale: scale)
        } else {
            startDateLabel.text?.removeAll()
            startHourLabel.text?.removeAll()
            endDateLabel.text?.removeAll()
            endHourLabel.text?.removeAll()
            scaleStatusLabel.text = scaleItem.status
        }
        updateTeamFromCloud(withTeamItem: scaleItem)
    }    
    private func updateTeamFromCloud(withTeamItem scaleItem: Scale_Item) {
        let context = container.viewContext
        let identifier = scaleItem.identifier ?? ""
        workingIndicator.show(at: self.contentView)
        fbDbRef.child(Scale.rootFirebaseDatabaseReference).child(identifier).observeSingleEvent(of: .value, with: {[weak self](snapshot) in
            if let scaleDic = snapshot.value as? NSDictionary {
                if let scale = Scale.createOrUpdate(matchDictionary: scaleDic, in: context) {
                    DispatchQueue.main.async {[weak self] in
                        self?.setup(withScale: scale)
                    }
                }
            }
            self?.workingIndicator.hide()
        })
    }
}

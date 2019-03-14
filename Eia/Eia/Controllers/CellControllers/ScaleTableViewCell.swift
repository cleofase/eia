//
//  ScaleTableViewCell.swift
//  Eia
//
//  Created by Cleofas Pereira on 11/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class ScaleTableViewCell: UITableViewCell {
    private let container: NSPersistentContainer = AppDelegate.persistentContainer!
    private let fbDbRef = Database.database().reference()
    public var scale: Scale?
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startHourLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endHourLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var teamNameLabel: UILabel!
    
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
        statusLabel.text = scale.status
        teamNameLabel.text = scale.team_name
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
            teamNameLabel.text?.removeAll()
            statusLabel.text = scaleItem.status
        }
        updateTeamFromCloud(withScaleId: scaleId)
    }
    public func setup(withScaleId scaleId: String) {
        let context = container.viewContext
        if let scale = Scale.find(matching: scaleId, in: context) {
            setup(withScale: scale)
        } else {
            startDateLabel.text?.removeAll()
            startHourLabel.text?.removeAll()
            endDateLabel.text?.removeAll()
            endHourLabel.text?.removeAll()
            teamNameLabel.text?.removeAll()
            statusLabel.text?.removeAll()
        }
        updateTeamFromCloud(withScaleId: scaleId)
    }
    private func updateTeamFromCloud(withScaleId scaleId: String) {
        let context = container.viewContext
        fbDbRef.child(Scale.rootFirebaseDatabaseReference).child(scaleId).observeSingleEvent(of: .value, with: {[weak self](snapshot) in
            if let scaleDic = snapshot.value as? NSDictionary {
                if let scale = Scale.createOrUpdate(matchDictionary: scaleDic, in: context) {
                    DispatchQueue.main.async {[weak self] in
                        self?.setup(withScale: scale)
                    }
                }
            }
        })
    }
}

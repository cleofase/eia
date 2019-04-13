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
    private let workingIndicator = WorkingIndicator()
    public var scale: Scale?
    
    @IBOutlet weak var startTextLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startHourLabel: UILabel!
    @IBOutlet weak var endTextLabel: UILabel!
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
        let scaleStatus = scale.status ?? ""
        var scaleTextColor = EiaColors.PembaSand
        if let scaleStatus = ScaleStatus(rawValue: scaleStatus) {
            scaleTextColor = getScaleStatusColor(with: scaleStatus)
        }
        startTextLabel.textColor = scaleTextColor
        startDateLabel.textColor = scaleTextColor
        startDateLabel.text = scale.start?.dateStringValue
        startHourLabel.textColor = scaleTextColor
        startHourLabel.text = scale.start?.hourStringValue
        endTextLabel.textColor = scaleTextColor
        endDateLabel.textColor = scaleTextColor
        endDateLabel.text = scale.end?.dateStringValue
        endHourLabel.textColor = scaleTextColor
        endHourLabel.text = scale.end?.hourStringValue
        statusLabel.textColor = scaleTextColor
        statusLabel.text = scale.status
        teamNameLabel.textColor = scaleTextColor
        teamNameLabel.text = scale.team_name
    }
    private func getScaleStatusColor(with scaleStatus: ScaleStatus) -> UIColor {
        switch scaleStatus {
        case .created:
            return EiaColors.PembaSand
        case .confirmed:
            return EiaColors.SunSet
        case .done:
            return EiaColors.PembaSandLight
        case .canceled:
            return EiaColors.PembaSandLight
        }
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
        workingIndicator.show(at: self.contentView)
        fbDbRef.child(Scale.rootFirebaseDatabaseReference).child(scaleId).observeSingleEvent(of: .value, with: {[weak self](snapshot) in
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

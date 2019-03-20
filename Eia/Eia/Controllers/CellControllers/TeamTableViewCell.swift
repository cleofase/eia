//
//  TeamTableViewCell.swift
//  Eia
//
//  Created by Cleofas Pereira on 30/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class TeamTableViewCell: UITableViewCell {
    private let container: NSPersistentContainer = AppDelegate.persistentContainer!
    private let fbDbRef = Database.database().reference()
    private let workingIndicator = WorkingIndicator()
    public var team: Team?
    
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var teamVolunteersLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    private func setup(with team: Team) {
        teamNameLabel.text = team.name
        var teamVolunteersName = ""
        if let teamVolunteerItems = team.volunteers?.allObjects as? [Voluntary_Item] {
            for teamVolunteerItem in teamVolunteerItems {
                if let volunteerName = teamVolunteerItem.name, !volunteerName.isEmpty {
                    if !teamVolunteersName.isEmpty {
                        teamVolunteersName.append(", ")
                    }
                    teamVolunteersName.append(volunteerName)
                }
            }
        }
        teamVolunteersLabel.text = teamVolunteersName
    }
    public func setup(withTeamItem teamItem: Team_Item) {
        let context = container.viewContext
        teamNameLabel.text = teamItem.name
        let teamId = teamItem.identifier ?? ""
        if let team = Team.find(matching: teamId, in: context) {
            setup(with: team)
        }
        updateTeamFromCloud(withTeamItem: teamItem)
    }
    private func updateTeamFromCloud(withTeamItem teamItem: Team_Item) {
        let context = container.viewContext
        let teamId = teamItem.identifier ?? ""
        workingIndicator.show(at: self.contentView)
        fbDbRef.child(Team.rootFirebaseDatabaseReference).child(teamId).observeSingleEvent(of: .value, with: {[weak self](snapshot) in
            if let teamDic = snapshot.value as? NSDictionary {
                DispatchQueue.main.async {[weak self] in
                    if let team = Team.createOrUpdate(matchDictionary: teamDic, in: context) {
                        self?.team = team
                        try? context.save()
                        self?.setup(with: team)
                    }
                }
            }
            self?.workingIndicator.hide()
        })
    }
}

//
//  GroupTeamTableViewCell.swift
//  Eia
//
//  Created by Cleofas Pereira on 27/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class GroupTeamTableViewCell: UITableViewCell {
    private let fbDbRef = Database.database().reference()
    private let container = AppDelegate.persistentContainer!
    private let workingIndicator = WorkingIndicator()
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)        
    }
    public func setup(withTeam team: Team) {
        nameLabel.text = team.name
    }
    public func setup(withTeamItem teamItem: Team_Item) {
        nameLabel.text = teamItem.name
        updateTeamFromCloud(withTeamItem: teamItem)
    }
    
    private func updateTeamFromCloud(withTeamItem teamItem: Team_Item) {
        let context = container.viewContext
        let identifier = teamItem.identifier ?? ""
        workingIndicator.show(at: self.contentView)
        fbDbRef.child(Team.rootFirebaseDatabaseReference).child(identifier).observeSingleEvent(of: .value, with: {[weak self](snapshot) in
            if let teamDic = snapshot.value as? NSDictionary {
                if let team = Team.createOrUpdate(matchDictionary: teamDic, in: context) {
                    DispatchQueue.main.async {[weak self] in
                        self?.setup(withTeam: team)
                    }
                }
            }
            self?.workingIndicator.hide()
        })
    }
    
}

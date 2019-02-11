//
//  GroupTeamsDataSource.swift
//  Eia
//
//  Created by Cleofas Pereira on 27/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class DetailGroupTeamsDataSource: NSObject {
    private let context: NSManagedObjectContext
    private let group: Group
    private let fbDbRef = Database.database().reference()
    
    init(withGroup group: Group, context: NSManagedObjectContext) {
        self.group = group
        self.context = context
    }
}

extension DetailGroupTeamsDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group.teams?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailGroupTeamCell", for: indexPath)
        if let cell = cell as? GroupTeamTableViewCell {
            if let teamsItemSet = group.teams, let teamItems = teamsItemSet.allObjects as? [Team_Item] {
                cell.setup(withTeamItem: teamItems[indexPath.row])
            }
            return cell
        }
        return cell
    }
}

//
//  DetailTeamVolunteersDataSource.swift
//  Eia
//
//  Created by Cleofas Pereira on 03/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class DetailTeamVolunteersDataSource: NSObject {
    private let context: NSManagedObjectContext
    private let team: Team
    private let fbDbRef = Database.database().reference()
    
    init(withTeam team: Team, context: NSManagedObjectContext) {
        self.team = team
        self.context = context
    }
}

extension DetailTeamVolunteersDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return team.volunteers?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailTeamVolunteerCell", for: indexPath)
        if let cell = cell as? GroupVolunteerTableViewCell {
            if let volunteersItemSet = team.volunteers, let volunteersItem = volunteersItemSet.allObjects as? [Voluntary_Item] {
                cell.setup(withVolunteerItem: volunteersItem[indexPath.row])
            }
            return cell
        }
        return cell
    }
}

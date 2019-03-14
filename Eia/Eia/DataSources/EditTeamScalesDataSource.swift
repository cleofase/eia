//
//  EditTeamScalesDataSource.swift
//  Eia
//
//  Created by Cleofas Pereira on 15/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class EditTeamScalesDataSource: NSObject {
    private let context: NSManagedObjectContext
    private let team: Team
    private let fbDbRef = Database.database().reference()
    
    init(withTeam team: Team, context: NSManagedObjectContext) {
        self.team = team
        self.context = context
    }
}

extension EditTeamScalesDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return team.scales?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editTeamScaleCell", for: indexPath)
        if let cell = cell as? TeamScaleTableViewCell {
            if let scalesItemSet = team.scales, let scaleItems = scalesItemSet.allObjects as? [Scale_Item] {
                cell.setup(withScaleItem: scaleItems[indexPath.row])
            }
            return cell
        }
        return cell
    }
}
extension EditTeamScalesDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}

//
//  DetailTeamScalesDataSource.swift
//  Eia
//
//  Created by Cleofas Pereira on 10/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class DetailTeamScalesDataSource: NSObject {
    private let context: NSManagedObjectContext
    private let team: Team
    private let fbDbRef = Database.database().reference()
    private let viewController: UIViewController
    
    init(withTeam team: Team, in context: NSManagedObjectContext, at viewController: UIViewController) {
        self.team = team
        self.context = context
        self.viewController = viewController
    }
}

extension DetailTeamScalesDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return team.scales?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailTeamScaleCell", for: indexPath)
        if let cell = cell as? TeamScaleTableViewCell {
            if let scalesItemSet = team.scales, let scaleItems = scalesItemSet.allObjects as? [Scale_Item] {
                cell.setup(withScaleItem: scaleItems[indexPath.row])
            }
            return cell
        }
        return cell
    }
}

extension DetailTeamScalesDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TeamScaleTableViewCell {
            viewController.performSegue(withIdentifier: "detailScaleFromTeamSegue", sender: cell.scale)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}

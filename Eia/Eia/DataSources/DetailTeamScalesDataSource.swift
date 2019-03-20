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
    private var team: Team
    private var scaleItems = [Scale_Item]()
    private let fbDbRef = Database.database().reference()
    private let viewController: UIViewController
    
    init(withTeam team: Team, in context: NSManagedObjectContext, at viewController: UIViewController) {
        self.team = team
        self.context = context
        self.viewController = viewController
        if let scaleItems = team.scales?.allObjects as? [Scale_Item] {
            self.scaleItems = scaleItems.sorted(by: {($0.start ?? Date()) > ($1.start ?? Date())})
        }
    }
    public func refresh() {
        let teamId = team.identifier ?? ""
        if let team = Team.find(matching: teamId, in: context) {
            self.team = team
            if let scaleItems = team.scales?.allObjects as? [Scale_Item] {
                self.scaleItems = scaleItems.sorted(by: {($0.start ?? Date()) > ($1.start ?? Date())})
            }
        }
    }
}

extension DetailTeamScalesDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scaleItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailTeamScaleCell", for: indexPath)
        if let cell = cell as? TeamScaleTableViewCell {
            cell.setup(withScaleItem: scaleItems[indexPath.row])
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

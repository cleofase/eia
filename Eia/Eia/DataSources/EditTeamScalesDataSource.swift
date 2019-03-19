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
    private var team: Team
    private var scaleItems = [Scale_Item]()
    private let fbDbRef = Database.database().reference()
    
    init(withTeam team: Team, context: NSManagedObjectContext) {
        self.team = team
        self.context = context
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

extension EditTeamScalesDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scaleItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editTeamScaleCell", for: indexPath)
        if let cell = cell as? TeamScaleTableViewCell {
            cell.setup(withScaleItem: scaleItems[indexPath.row])
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

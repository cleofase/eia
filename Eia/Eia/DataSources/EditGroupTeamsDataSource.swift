//
//  EditGroupTeamsDataSource.swift
//  Eia
//
//  Created by Cleofas Pereira on 27/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class EditGroupTeamsDataSource: NSObject {
    private let context: NSManagedObjectContext
    private var group: Group
    private var teamItems = [Team_Item]()
    private let fbDbRef = Database.database().reference()
    
    init(withGroup group: Group, context: NSManagedObjectContext) {
        self.group = group
        self.context = context
        if let teamItems = group.teams?.allObjects as? [Team_Item] {
            self.teamItems = teamItems.sorted(by: {($0.name ?? "") < ($1.name ?? "")})
        }
    }
    public func refresh() {
        let groupId = group.identifier ?? ""
        if let group = Group.find(matching: groupId, in: context) {
            self.group = group
            if let teamItems = group.teams?.allObjects as? [Team_Item] {
                self.teamItems = teamItems.sorted(by: {($0.name ?? "") < ($1.name ?? "")})
            }
        }
    }
}

extension EditGroupTeamsDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editGroupTeamCell", for: indexPath)
        if let cell = cell as? GroupTeamTableViewCell {
            cell.setup(withTeamItem: teamItems[indexPath.row])
            return cell
        }
        return cell
    }
}

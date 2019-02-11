//
//  NewTeamVolunteersDataSource.swift
//  Eia
//
//  Created by Cleofas Pereira on 27/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class NewTeamVolunteersDataSource: NSObject {
    private let context: NSManagedObjectContext
    private let group: Group
    private var groupVolunteerItens = [Voluntary_Item]()
    private let fbDbRef = Database.database().reference()
    public var selectedVolunteerItems = [Voluntary_Item]()
    
    init(withGroup group: Group, context: NSManagedObjectContext) {
        self.group = group
        self.context = context
        self.groupVolunteerItens = group.volunteers?.allObjects as? [Voluntary_Item] ?? [Voluntary_Item]()
    }
}

extension NewTeamVolunteersDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupVolunteerItens.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newTeamVolunteerCell", for: indexPath)
        if let cell = cell as? GroupVolunteerTableViewCell {
            cell.setup(withVolunteerItem: groupVolunteerItens[indexPath.row])
            return cell
        }
        return cell
    }
}

extension NewTeamVolunteersDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedVolunteerItems.append(groupVolunteerItens[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let index = selectedVolunteerItems.firstIndex(of: groupVolunteerItens[indexPath.row]) {
            selectedVolunteerItems.remove(at: index)
        }
    }
}

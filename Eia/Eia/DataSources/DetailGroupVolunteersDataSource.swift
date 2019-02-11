//
//  DetailGroupVolunteersDataSource.swift
//  Eia
//
//  Created by Cleofas Pereira on 23/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class DetailGroupVolunteersDataSource: NSObject {
    private let context: NSManagedObjectContext
    private let group: Group
    private let fbDbRef = Database.database().reference()
    
    init(withGroup group: Group, context: NSManagedObjectContext) {
        self.group = group
        self.context = context
    }
}

extension DetailGroupVolunteersDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group.volunteers?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailGroupVolunteerCell", for: indexPath)
        if let cell = cell as? GroupVolunteerTableViewCell {
            if let volunteersItemSet = group.volunteers, let volunteersItem = volunteersItemSet.allObjects as? [Voluntary_Item] {
                cell.setup(withVolunteerItem: volunteersItem[indexPath.row])
            }
            return cell
        }
        return cell
    }
}

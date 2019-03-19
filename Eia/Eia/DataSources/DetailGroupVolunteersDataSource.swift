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
    private var group: Group
    private var volunteerItems = [Voluntary_Item]()
    private let fbDbRef = Database.database().reference()
    
    init(withGroup group: Group, context: NSManagedObjectContext) {
        self.group = group
        self.context = context
        if let volunteerItems = group.volunteers?.allObjects as? [Voluntary_Item] {
            self.volunteerItems = volunteerItems.sorted(by: {($0.name ?? "") < ($1.name ?? "")})
        }
    }
    public func refresh() {
        let groupId = self.group.identifier ?? ""
        if let group = Group.find(matching: groupId, in: context) {
            self.group = group
            if let volunteerItems = group.volunteers?.allObjects as? [Voluntary_Item] {
                self.volunteerItems = volunteerItems.sorted(by: {($0.name ?? "") < ($1.name ?? "")})
            }
        }
    }
}

extension DetailGroupVolunteersDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return volunteerItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailGroupVolunteerCell", for: indexPath)
        if let cell = cell as? GroupVolunteerTableViewCell {
            cell.setup(withVolunteerItem: volunteerItems[indexPath.row])
            return cell
        }
        return cell
    }
}

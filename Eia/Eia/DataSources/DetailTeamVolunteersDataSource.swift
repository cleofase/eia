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
    private var team: Team
    private var volunteerItems = [Voluntary_Item]()
    private let fbDbRef = Database.database().reference()
    
    init(withTeam team: Team, context: NSManagedObjectContext) {
        self.team = team
        self.context = context
        if let volunteerItems = team.volunteers?.allObjects as? [Voluntary_Item] {
            self.volunteerItems = volunteerItems.sorted(by: {($0.name ?? "") < ($1.name ?? "")})
        }
    }
    public func refresh() {
        let teamId = team.identifier ?? ""
        if let team = Team.find(matching: teamId, in: context) {
            self.team = team
            if let volunteerItems = team.volunteers?.allObjects as? [Voluntary_Item] {
                self.volunteerItems = volunteerItems.sorted(by: {($0.name ?? "") < ($1.name ?? "")})
            }
        }
    }
}

extension DetailTeamVolunteersDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return volunteerItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailTeamVolunteerCell", for: indexPath)
        if let cell = cell as? GroupVolunteerTableViewCell {
            cell.setup(withVolunteerItem: volunteerItems[indexPath.row])
            return cell
        }
        return cell
    }
}

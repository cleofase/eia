//
//  NewScaleVolunteersDataSource.swift
//  Eia
//
//  Created by Cleofas Pereira on 07/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class NewScaleVolunteersDataSource: NSObject {
    private let context: NSManagedObjectContext
    private var team: Team
    private var teamVolunteerItems = [Voluntary_Item]()
    private let fbDbRef = Database.database().reference()
    public var selectedVolunteerItems = [Voluntary_Item]()
    
    init(withTeam team: Team, context: NSManagedObjectContext) {
        self.team = team
        self.context = context
        if let teamVolunteerItems = team.volunteers?.allObjects as? [Voluntary_Item] {
            self.teamVolunteerItems = teamVolunteerItems.sorted(by: {($0.name ?? "") < ($1.name ?? "")})
        }
    }
    public func refresh() {
        let teamId = team.identifier ?? ""
        if let team = Team.find(matching: teamId, in: context) {
            self.team = team
            if let teamVolunteerItems = team.volunteers?.allObjects as? [Voluntary_Item] {
                self.teamVolunteerItems = teamVolunteerItems.sorted(by: {($0.name ?? "") < ($1.name ?? "")})
            }
        }
    }
}

extension NewScaleVolunteersDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamVolunteerItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newScaleVolunteerCell", for: indexPath)
        if let cell = cell as? GroupVolunteerTableViewCell {
            cell.setup(withVolunteerItem: teamVolunteerItems[indexPath.row])
            return cell
        }
        return cell
    }
}

extension NewScaleVolunteersDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedVolunteerItems.append(teamVolunteerItems[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let index = selectedVolunteerItems.firstIndex(of: teamVolunteerItems[indexPath.row]) {
            selectedVolunteerItems.remove(at: index)
        }
    }
}

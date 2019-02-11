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
    private let team: Team
    private var teamVolunteerItens = [Voluntary_Item]()
    private let fbDbRef = Database.database().reference()
    public var selectedVolunteerItems = [Voluntary_Item]()
    
    init(withTeam team: Team, context: NSManagedObjectContext) {
        self.team = team
        self.context = context
        self.teamVolunteerItens = team.volunteers?.allObjects as? [Voluntary_Item] ?? [Voluntary_Item]()
    }
}

extension NewScaleVolunteersDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamVolunteerItens.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newScaleVolunteerCell", for: indexPath)
        if let cell = cell as? GroupVolunteerTableViewCell {
            cell.setup(withVolunteerItem: teamVolunteerItens[indexPath.row])
            return cell
        }
        return cell
    }
}

extension NewScaleVolunteersDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedVolunteerItems.append(teamVolunteerItens[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let index = selectedVolunteerItems.firstIndex(of: teamVolunteerItens[indexPath.row]) {
            selectedVolunteerItems.remove(at: index)
        }
    }
}

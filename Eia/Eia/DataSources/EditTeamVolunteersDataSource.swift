//
//  EditTeamVolunteersDataSource.swift
//  Eia
//
//  Created by Cleofas Pereira on 15/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class EditTeamVolunteersDataSource: NSObject {
    private let context: NSManagedObjectContext
    private let team: Team
    private let teamVolunteerItems: [Voluntary_Item]
    private var volunteers = [Voluntary]()
    private let fbDbRef = Database.database().reference()
    public var selectedVolunteerItems = [Voluntary_Item]()
    lazy public var removedVolunteerItems: [Voluntary_Item] = {
        return teamVolunteerItems.filter({(oldItem) in
            return !selectedVolunteerItems.contains(where: {(selectedItem) in
                let selectedItemId = selectedItem.identifier ?? ""
                let oldItemId = oldItem.identifier ?? ""
                return selectedItemId == oldItemId
            })
        })
    }()
    
    init(withTeam team: Team, context: NSManagedObjectContext) {
        self.team = team
        self.teamVolunteerItems = team.volunteers?.allObjects as? [Voluntary_Item] ?? [Voluntary_Item]()
        self.context = context
    }
    private func updateVolunteersFromCloud(inContext context: NSManagedObjectContext, didUpdateWithSuccess: @escaping () -> Void) {
        fbDbRef.child(Voluntary.rootFirebaseDatabaseReference).observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
            guard let allVolunteersDic = snapshot.value as? NSDictionary else {return}
            self?.volunteers.removeAll()
            for volunteerDic in allVolunteersDic.allValues {
                if let volunteerDic = volunteerDic as? NSDictionary {
                    if let volunteer = Voluntary.createOrUpdate(matchDictionary: volunteerDic, in: context) {
                        self?.volunteers.append(volunteer)
                    }
                }
            }
            if let sortedVolunteers = self?.volunteers.sorted(by: {($0.name ?? "") < ($1.name ?? "")}) {
                self?.volunteers = sortedVolunteers
            }
            didUpdateWithSuccess()
        })
    }
    public func update(didUpdateWithSuccess: @escaping () -> Void) {
        updateVolunteersFromCloud(inContext: context) {
            didUpdateWithSuccess()
        }
    }
}

extension EditTeamVolunteersDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return volunteers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editTeamVolunteerCell", for: indexPath)
        if let cell = cell as? GroupVolunteerTableViewCell {
            let volunteer = volunteers[indexPath.row]
            cell.setup(withVolunteer: volunteer)
            if teamVolunteerItems.contains(where: {(voluntaryItem) in
                return voluntaryItem.identifier == volunteer.authId
            }) {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
            }
            return cell
        }
        return cell
    }
}

extension EditTeamVolunteersDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let volunteerItem = Voluntary_Item.create(withVoluntary: volunteers[indexPath.row], in: context)
        selectedVolunteerItems.append(volunteerItem)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let volunteer = volunteers[indexPath.row]
        if let index = selectedVolunteerItems.firstIndex(where: {$0.identifier == volunteer.authId}) {
            selectedVolunteerItems.remove(at: index)
        }
    }
}

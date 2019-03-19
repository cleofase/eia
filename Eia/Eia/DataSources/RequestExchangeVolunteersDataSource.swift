//
//  RequestExchangeVolunteersDataSource.swift
//  Eia
//
//  Created by Cleofas Pereira on 07/03/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class RequestExchangeVolunteersDataSource: NSObject {
    public var selectedVoluntary: Voluntary_Item?
    private let context: NSManagedObjectContext
    private let scale: Scale
    private var voluntaryItems = [Voluntary_Item]()
    private let fbDbRef = Database.database().reference()
    
    init(withScale scale: Scale, context: NSManagedObjectContext) {
        self.context = context
        self.scale = scale
        super.init()
        updateVoluntaryItems()
    }
    private func updateVoluntaryItems() {
        let teamId = scale.team_id ?? ""
        if let team = Team.find(matching: teamId, in: context) {
            let groupId = team.group_id ?? ""
            if let group = Group.find(matching: groupId, in: context) {
                loadVoluntaryItems(withGroup: group)
            } else {
                fbDbRef.child(Group.rootFirebaseDatabaseReference).child(groupId).observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
                    guard let strongSelf = self else {return}
                    if let groupDic = snapshot.value as? NSDictionary {
                        if let group = Group.create(withDictionary: groupDic, in: strongSelf.context) {
                            try? strongSelf.context.save()
                            strongSelf.loadVoluntaryItems(withGroup: group)
                        }
                    }
                })
            }
        }
    }
    private func loadVoluntaryItems(withGroup group: Group) {
        if let groupVoluntaryItems = group.volunteers?.allObjects as? [Voluntary_Item] {
            if let invitations = scale.invitations?.allObjects as? [Invitation_Item] {
                voluntaryItems = groupVoluntaryItems.filter({(voluntaryItem) in
                    let teamVoluntaryId = voluntaryItem.identifier ?? ""
                    return !invitations.contains(where: {(invitationItem) in
                        let invitationVoluntaryId = invitationItem.voluntary_id ?? ""
                        if invitationVoluntaryId == teamVoluntaryId {
                            return true
                        } else {
                            return false
                        }
                    })
                }).sorted(by: {($0.name ?? "") < ($1.name ?? "")})
            }
        }
    }

}

extension RequestExchangeVolunteersDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voluntaryItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestExchangeVolunteerCell", for: indexPath)
        if let cell = cell as? GroupVolunteerTableViewCell {
            cell.setup(withVolunteerItem: voluntaryItems[indexPath.row])
            return cell
        }
        return cell
    }
}

extension RequestExchangeVolunteersDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedVoluntary = voluntaryItems[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedVoluntary = nil
    }
}

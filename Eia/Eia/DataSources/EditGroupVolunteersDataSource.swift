//
//  EditGroupVolunteersDataSource.swift
//  Eia
//
//  Created by Cleofas Pereira on 26/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class EditGroupVolunteersDataSource: NSObject {
    private let context: NSManagedObjectContext
    private let group: Group
    private let groupVolunteerItems: [Voluntary_Item]
    private var volunteers = [Voluntary]()
    private let fbDbRef = Database.database().reference()
    public var selectedVolunteerItems = [Voluntary_Item]()
    
    public var addedVolunteerItems: [Voluntary_Item] {
        get {
            return selectedVolunteerItems.filter({(selectedItem) in
                return !groupVolunteerItems.contains(where: {(oldItem) in
                    let selectedItemId = selectedItem.identifier ?? ""
                    let oldItemId = oldItem.identifier ?? ""
                    return selectedItemId == oldItemId
                })
            })
        }
    }
    public var removedVolunteerItems: [Voluntary_Item] {
        get {
            return groupVolunteerItems.filter({(oldItem) in
                return !selectedVolunteerItems.contains(where: {(selectedItem) in
                    let selectedItemId = selectedItem.identifier ?? ""
                    let oldItemId = oldItem.identifier ?? ""
                    return selectedItemId == oldItemId
                })
            })
        }
    }
    public var notChangedVolunteerItems: [Voluntary_Item] {
        get {
            return groupVolunteerItems.filter({(oldItem) in
                return selectedVolunteerItems.contains(where: {(selectedItem) in
                    let selectedItemId = selectedItem.identifier ?? ""
                    let oldItemId = oldItem.identifier ?? ""
                    return selectedItemId == oldItemId
                })
            })
        }
    }
    init(withGroup group: Group, context: NSManagedObjectContext) {
        self.group = group
        self.groupVolunteerItems = group.volunteers?.allObjects as? [Voluntary_Item] ?? [Voluntary_Item]()
        self.selectedVolunteerItems = groupVolunteerItems
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

extension EditGroupVolunteersDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return volunteers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editGroupVolunteerCell", for: indexPath)
        if let cell = cell as? GroupVolunteerTableViewCell {
            let volunteer = volunteers[indexPath.row]
            cell.setup(withVolunteer: volunteer)
            if groupVolunteerItems.contains(where: {(voluntaryItem) in
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
extension EditGroupVolunteersDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let volunteer = volunteers[indexPath.row]
        if !selectedVolunteerItems.contains(where: {$0.identifier == volunteer.authId}) {
            let volunteerItem = Voluntary_Item.create(withVoluntary: volunteer, in: context)
            selectedVolunteerItems.append(volunteerItem)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let volunteer = volunteers[indexPath.row]
        if let index = selectedVolunteerItems.firstIndex(where: {$0.identifier == volunteer.authId}) {
            selectedVolunteerItems.remove(at: index)
        }
    }
}

//
//  NewGroupVolunteersDataSource.swift
//  Eia
//
//  Created by Cleofas Pereira on 22/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class NewGroupVolunteersDataSource: NSObject {
    private let context: NSManagedObjectContext
    private let leaderId: String
    private var volunteers = [Voluntary]()
    private let fbDbRef = Database.database().reference()
    public var selectedVolunteers = [Voluntary]()
    
    init(withLeaderId leaderId: String, context: NSManagedObjectContext) {
        self.leaderId = leaderId
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

extension NewGroupVolunteersDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return volunteers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupVolunteerCell", for: indexPath)
        if let cell = cell as? GroupVolunteerTableViewCell {
            cell.setup(withVolunteer: volunteers[indexPath.row])
            return cell
        }
        return cell
    }
}

extension NewGroupVolunteersDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedVolunteers.append(volunteers[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let index = selectedVolunteers.firstIndex(of: volunteers[indexPath.row]) {
            selectedVolunteers.remove(at: index)
        }
    }
}

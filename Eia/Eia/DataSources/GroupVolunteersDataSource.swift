//
//  GroupVolunteersDataSource.swift
//  Eia
//
//  Created by Cleofas Pereira on 19/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class GroupVolunteersDataSource: NSObject, UITableViewDataSource {
    private let context: NSManagedObjectContext
    private var group: Group
    private var volunteers = [Voluntary]()
    private let fbDbRef = Database.database().reference()
    
    init(withGroup group: Group, context: NSManagedObjectContext) {
        self.group = group
        self.context = context
    }
    
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
    
    private func updateVolunteersFromCloud(inContext context: NSManagedObjectContext, didUpdateWithSuccess: @escaping () -> Void) {
        fbDbRef.child(Voluntary.rootFirebaseDatabaseReference).observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
            guard let allVolunteersDic = snapshot.value as? NSDictionary else {return}
            self?.volunteers.removeAll()
            for volunteerDic in allVolunteersDic.allValues {
                if let volunteerDic = volunteerDic as? NSDictionary {
                    if let volunteer = Voluntary.createOrUpdate(matchDictionary: volunteerDic, in: context) {
                        let leaderId = self?.group.leader_id ?? ""
                        if volunteer.authId != leaderId {
                            self?.volunteers.append(volunteer)
                        }
                    }
                }
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

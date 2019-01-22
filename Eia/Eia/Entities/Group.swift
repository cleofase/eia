//
//  Group.swift
//  Eia
//
//  Created by Cleofas Pereira on 05/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

class Group: NSManagedObject {
    class func find(matching identifier: String, in context: NSManagedObjectContext) -> Group? {
        let request: NSFetchRequest<Group> = Group.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", identifier)
        if let matches = try? context.fetch(request) {
            if matches.count > 0 {
                return matches.first
            }
        }
        return nil
    }
    class func create(withName name: String, description: String, leaderName: String, leaderId: String, volunteers: [Voluntary], in context: NSManagedObjectContext) -> Group? {
        let group = Group(context: context)
        group.identifier = UUID().uuidString
        group.name = name
        group.group_description = description
        group.leader_id = leaderId
        group.leader_name = leaderName
        if volunteers.count > 0 {
            var volunteersItems = [Voluntary_Item]()
            for volunteer in volunteers {
                let voluntaryItem = Voluntary_Item.create(withVoluntary: volunteer, in: context)
                volunteersItems.append(voluntaryItem)
            }
            group.volunteers = NSSet(array: volunteersItems)
        }
        return group
    }
    class func create(withDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Group? {
        let group = Group(context: context)
        if let identifier = dictionary["identifier"] as? String {
            group.identifier = identifier
        } else {return nil}
        if let name = dictionary["name"] as? String {
            group.name = name
        } else {return nil}
        if let group_description = dictionary["group_description"] as? String {
            group.group_description = group_description
        } else {return nil}
        if let leader_id = dictionary["leader_id"] as? String {
            group.leader_id = leader_id
        } else {return nil}
        if let leader_name = dictionary["leader_name"] as? String {
            group.leader_name = leader_name
        } else {return nil}
        if let status = dictionary["status"] as? String {
            group.status = status
        } else {return nil}
        if let photo_str = dictionary["photo_str"] as? String {
            group.photo_str = photo_str
        }
        if let photo_url = dictionary["photo_url"] as? String {
            group.photo_url = photo_url
        }
        if let volunteers = dictionary["volunteers"] as? NSDictionary {
            group.volunteers = NSSet(array: Voluntary_Item.createOrUpdate(withList: volunteers, in: context))
        }
        if let teams = dictionary["teams"] as? NSDictionary {
            group.teams = NSSet(array: Team_Item.createOrUpdate(withList: teams, in: context))
        }
        return group
    }
    class func createOrUpdate(matchDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Group? {
        var group: Group? = nil
        if let identifier = dictionary["identifier"] as? String {
            group = Group.find(matching: identifier, in: context)
            if let group = group {
                if let name = dictionary["name"] as? String {
                    group.name = name
                }
                if let group_description = dictionary["group_description"] as? String {
                    group.group_description = group_description
                }
                if let leader_id = dictionary["leader_id"] as? String {
                    group.leader_id = leader_id
                }
                if let leader_name = dictionary["leader_name"] as? String {
                    group.leader_name = leader_name
                }
                if let status = dictionary["status"] as? String {
                    group.status = status
                }
                if let photo_str = dictionary["photo_str"] as? String {
                    group.photo_str = photo_str
                }
                if let photo_url = dictionary["photo_url"] as? String {
                    group.photo_url = photo_url
                }
                if let volunteers = dictionary["volunteers"] as? NSDictionary {
                    group.volunteers = NSSet(array: Voluntary_Item.createOrUpdate(withList: volunteers, in: context))
                }
                if let teams = dictionary["teams"] as? NSDictionary {
                    group.teams = NSSet(array: Team_Item.createOrUpdate(withList: teams, in: context))
                }
            } else {
                group = Group.create(withDictionary: dictionary, in: context)
            }
        }
        return group
    }
    private func dictionaryValueForVolunteers() -> [String: Any] {
        var dictionary = [String: Any]()
        if let volunteers = volunteers {
            for voluntary in volunteers {
                if let voluntary = voluntary as? Voluntary_Item, let identifier = voluntary.identifier {
                    dictionary.updateValue(voluntary.dictionaryValue, forKey: identifier)
                }
            }
        }
        return dictionary
    }
    private func dictionaryValueForTeams() -> [String: Any] {
        var dictionary = [String: Any]()
        if let teams = teams {
            for team in teams {
                if let team = team as? Team_Item, let identifier = team.identifier {
                    dictionary.updateValue(team.dictionaryValue, forKey: identifier)
                }
            }
        }
        return dictionary
    }
    var dictionaryValue: [String: Any] {
        get {
            return [
                "identifier": identifier ?? "",
                "name": name ?? "",
                "group_description": group_description ?? "",
                "leader_id": leader_id ?? "",
                "leader_name": leader_name ?? "",
                "photo_str": photo_str ?? "",
                "photo_url": photo_url ?? "",
                "status": status ?? "",
                "volunteers": dictionaryValueForVolunteers(),
                "teams": dictionaryValueForTeams()
            ]
        }
    }
    class var rootFirebaseDatabaseReference: String {
        get {
            return "group"
        }
    }
}

//
//  Team.swift
//  Eia
//
//  Created by Cleofas Pereira on 05/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

enum TeamStatus: String {
    case active = "ATIVA"
    case inactive = "INATIVA"
    var stringValue: String {get{
        return self.rawValue
        }}
}
class Team: NSManagedObject {
    class func find(matching identifier: String, in context: NSManagedObjectContext) -> Team? {
        let request: NSFetchRequest<Team> = Team.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", identifier)
        if let matches = try? context.fetch(request) {
            if matches.count > 0 {
                return matches.first
            }
        }
        return nil
    }
    class func create(withName name: String, group: Group, volunteerItems: [Voluntary_Item], in context: NSManagedObjectContext) -> Team {
        let team = Team(context: context)
        team.identifier = UUID().uuidString
        team.name = name
        team.leader_id = group.leader_id
        team.leader_name = group.leader_name
        team.group_id = group.identifier
        team.group_name = group.name
        team.status = TeamStatus.active.stringValue
        team.volunteers = NSSet(array: volunteerItems)
        return team
    }
    class func create(withDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Team? {
        let team = Team(context: context)
        if let identifier = dictionary["identifier"] as? String {
            team.identifier = identifier
        } else {return nil}
        if let name = dictionary["name"] as? String {
            team.name = name
        } else {return nil}
        if let leader_id = dictionary["leader_id"] as? String {
            team.leader_id = leader_id
        } else {return nil}
        if let leader_name = dictionary["leader_name"] as? String {
            team.leader_name = leader_name
        } else {return nil}
        if let group_id = dictionary["group_id"] as? String {
            team.group_id = group_id
        } else {return nil}
        if let group_name = dictionary["group_name"] as? String {
            team.group_name = group_name
        } else {return nil}
        if let status = dictionary["status"] as? String {
            team.status = status
        } else {return nil}
        if let volunteers = dictionary["volunteers"] as? NSDictionary {
            team.volunteers = NSSet(array: Voluntary_Item.createOrUpdate(withList: volunteers, in: context))
        }
        if let scales = dictionary["scales"] as? NSDictionary {
            team.scales = NSSet(array: Scale_Item.createOrUpdate(withList: scales, in: context))
        }
        return team
    }
    class func createOrUpdate(matchDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Team? {
        var team: Team? = nil
        if let identifier = dictionary["identifier"] as? String {
            team = Team.find(matching: identifier, in: context)
            if let team = team {
                if let name = dictionary["name"] as? String {
                    team.name = name
                }
                if let leader_id = dictionary["leader_id"] as? String {
                    team.leader_id = leader_id
                }
                if let leader_name = dictionary["leader_name"] as? String {
                    team.leader_name = leader_name
                }
                if let group_id = dictionary["group_id"] as? String {
                    team.group_id = group_id
                }
                if let group_name = dictionary["group_name"] as? String {
                    team.group_name = group_name
                }
                if let status = dictionary["status"] as? String {
                    team.status = status
                }
                if let volunteers = dictionary["volunteers"] as? NSDictionary {
                    team.volunteers = NSSet(array: Voluntary_Item.createOrUpdate(withList: volunteers, in: context))
                }
                if let scales = dictionary["scales"] as? NSDictionary {
                    team.scales = NSSet(array: Scale_Item.createOrUpdate(withList: scales, in: context))
                }
            } else {
                team = Team.create(withDictionary: dictionary, in: context)
            }
        }
        return team
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
    private func dictionaryValueForScales() -> [String: Any] {
        var dictionary = [String: Any]()
        if let scales = scales {
            for scale in scales {
                if let scale = scale as? Scale_Item, let identifier = scale.identifier {
                    dictionary.updateValue(scale.dictionaryValue, forKey: identifier)
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
                "leader_id": leader_id ?? "",
                "leader_name": leader_name ?? "",
                "group_id": group_id ?? "",
                "group_name": group_name ?? "",
                "status": status ?? "",
                "volunteers": dictionaryValueForVolunteers(),
                "scales": dictionaryValueForScales()
            ]
        }
    }
    class var rootFirebaseDatabaseReference: String {
        get {
            return "team"
        }
    }
}

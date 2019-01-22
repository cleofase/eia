//
//  Team_Item.swift
//  Eia
//
//  Created by Cleofas Pereira on 05/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

class Team_Item: NSManagedObject {
    class func find(matching identifier: String, in context: NSManagedObjectContext) -> Team_Item? {
        let request: NSFetchRequest<Team_Item> = Team_Item.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", identifier)
        if let matches = try? context.fetch(request) {
            if matches.count > 0 {
                return matches.first
            }
        }
        return nil
    }
    class func create(withDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Team_Item? {
        let teamItem = Team_Item(context: context)
        if let identifier = dictionary["identifier"] as? String {
            teamItem.identifier = identifier
        } else {return nil}
        if let name = dictionary["name"] as? String {
            teamItem.name = name
        } else {return nil}
        return teamItem
    }
    class func createOrUpdate(matchDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Team_Item? {
        var teamItem: Team_Item? = nil
        if let identifier = dictionary["identifier"] as? String {
            teamItem = Team_Item.find(matching: identifier, in: context)
            if let teamItem = teamItem {
                if let name = dictionary["name"] as? String {
                    teamItem.name = name
                }
            } else {
                teamItem = Team_Item.create(withDictionary: dictionary, in: context)
            }
        }
        return teamItem
    }
    class func createOrUpdate(withList dictionary: NSDictionary, in context: NSManagedObjectContext) -> [Team_Item] {
        var teamItems = [Team_Item]()
        for dicForOneItem in dictionary.allValues {
            if let dicForOneItem = dicForOneItem as? NSDictionary {
                if let teamItem = Team_Item.createOrUpdate(matchDictionary: dicForOneItem, in: context) {
                    teamItems.append(teamItem)
                }
            }
        }
        return teamItems
    }
    var dictionaryValue: [String: Any] {
        get {
            return [
                "identifier": identifier ?? "",
                "name": name ?? ""
            ]
        }
    }
}

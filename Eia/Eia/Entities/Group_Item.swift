//
//  Group_Item.swift
//  Eia
//
//  Created by Cleofas Pereira on 05/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

class Group_Item: NSManagedObject {
    class func find(matching identifier: String, in context: NSManagedObjectContext) -> Group_Item? {
        let request: NSFetchRequest<Group_Item> = Group_Item.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", identifier)
        if let matches = try? context.fetch(request) {
            if matches.count > 0 {
                return matches.first
            }
        }
        return nil
    }
    class func create(withGroup group: Group, in context: NSManagedObjectContext) -> Group_Item {
        let groupItem = Group_Item(context: context)
        groupItem.identifier = group.identifier
        groupItem.name = group.name
        return groupItem
    }
    class func create(withDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Group_Item? {
        let groupItem = Group_Item(context: context)
        if let identifier = dictionary["identifier"] as? String {
            groupItem.identifier = identifier
        } else {return nil}
        if let name = dictionary["name"] as? String {
            groupItem.name = name
        } else {return nil}
        return groupItem
    }
    class func createOrUpdate(matchDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Group_Item? {
        var groupItem: Group_Item? = nil
        if let identifier = dictionary["identifier"] as? String {
            groupItem = Group_Item.find(matching: identifier, in: context)
            if let groupItem = groupItem {
                if let name = dictionary["name"] as? String {
                    groupItem.name = name
                }
            } else {
                groupItem = Group_Item.create(withDictionary: dictionary, in: context)
            }
        }
        return groupItem
    }
    class func createOrUpdate(withList dictionary: NSDictionary, in context: NSManagedObjectContext) -> [Group_Item] {
        var groupItems = [Group_Item]()
        for dicForOneItem in dictionary.allValues {
            if let dicForOneItem = dicForOneItem as? NSDictionary {
                if let groupItem = Group_Item.createOrUpdate(matchDictionary: dicForOneItem, in: context) {
                    groupItems.append(groupItem)
                }
            }
        }
        return groupItems
    }
    var dictionaryValue: [String: Any] {
        get {
            return [
                "identifier": identifier ?? "",
                "name": name ?? ""
            ]
        }
    }
    class var rootFirebaseDatabaseReference: String {
        get {
            return "groups"
        }
    }
}

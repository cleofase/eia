//
//  Voluntary_Item.swift
//  Eia
//
//  Created by Cleofas Pereira on 05/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

class Voluntary_Item: NSManagedObject {
    class func find(matching identifier: String, in context: NSManagedObjectContext) -> Voluntary_Item? {
        let request: NSFetchRequest<Voluntary_Item> = Voluntary_Item.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", identifier)
        if let matches = try? context.fetch(request) {
            if matches.count > 0 {
                return matches.first
            }
        }
        return nil
    }
    class func create(withVoluntary voluntary: Voluntary, in context: NSManagedObjectContext) -> Voluntary_Item {
        let voluntaryItem = Voluntary_Item(context: context)
        voluntaryItem.identifier = voluntary.identifier
        voluntaryItem.name = voluntary.name
        return voluntaryItem
    }
    class func create(withDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Voluntary_Item? {
        let voluntaryItem = Voluntary_Item(context: context)
        if let identifier = dictionary["identifier"] as? String {
            voluntaryItem.identifier = identifier
        } else {return nil}
        if let name = dictionary["name"] as? String {
            voluntaryItem.name = name
        } else {return nil}
        return voluntaryItem
    }
    class func createOrUpdate(matchDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Voluntary_Item? {
        var voluntaryItem: Voluntary_Item? = nil
        if let identifier = dictionary["identifier"] as? String {
            voluntaryItem = Voluntary_Item.find(matching: identifier, in: context)
            if let voluntaryItem = voluntaryItem {
                if let name = dictionary["name"] as? String {
                    voluntaryItem.name = name
                }
            } else {
                voluntaryItem = Voluntary_Item.create(withDictionary: dictionary, in: context)
            }
        }
        return voluntaryItem
    }
    class func createOrUpdate(withList dictionary: NSDictionary, in context: NSManagedObjectContext) -> [Voluntary_Item] {
        var voluntaryItems = [Voluntary_Item]()
        for dicForOneItem in dictionary.allValues {
            if let dicForOneItem = dicForOneItem as? NSDictionary {
                if let voluntaryItem = Voluntary_Item.createOrUpdate(matchDictionary: dicForOneItem, in: context) {
                    voluntaryItems.append(voluntaryItem)
                }
            }
        }
        return voluntaryItems
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

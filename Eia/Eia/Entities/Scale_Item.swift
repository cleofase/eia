//
//  Scale_Item.swift
//  Eia
//
//  Created by Cleofas Pereira on 05/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

class Scale_Item: NSManagedObject {
    class func find(matching identifier: String, in context: NSManagedObjectContext) -> Scale_Item? {
        let request: NSFetchRequest<Scale_Item> = Scale_Item.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", identifier)
        if let matches = try? context.fetch(request) {
            if matches.count > 0 {
                return matches.first
            }
        }
        return nil
    }
    class func create(withScale scale: Scale, in context: NSManagedObjectContext) -> Scale_Item {
        let scaleItem = Scale_Item(context: context)
        scaleItem.identifier = scale.identifier
        scaleItem.status = scale.status
        scaleItem.start = scale.start
        return scaleItem
    }
    class func create(withDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Scale_Item? {
        let scaleItem = Scale_Item(context: context)
        if let identifier = dictionary["identifier"] as? String {
            scaleItem.identifier = identifier
        } else {return nil}
        if let status = dictionary["status"] as? String {
            scaleItem.status = status
        } else {return nil}
        if let strStart = dictionary["start"] as? String {
            if let startAsInterval = UInt64(strStart) {
                scaleItem.start = Date(timeIntervalSince1970: TimeInterval(bitPattern: startAsInterval))
            } else {return nil}
        } else {return nil}
        return scaleItem
    }
    class func createOrUpdate(matchDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Scale_Item? {
        var scaleItem: Scale_Item? = nil
        if let identifier = dictionary["identifier"] as? String {
            scaleItem = Scale_Item.find(matching: identifier, in: context)
            if let scaleItem = scaleItem {
                if let status = dictionary["status"] as? String {
                    scaleItem.status = status
                }
                if let strStart = dictionary["start"] as? String {
                    if let startAsInterval = UInt64(strStart) {
                        scaleItem.start = Date(timeIntervalSince1970: TimeInterval(bitPattern: startAsInterval))
                    }
                }
            } else {
                scaleItem = Scale_Item.create(withDictionary: dictionary, in: context)
            }
        }
        return scaleItem
    }
    class func createOrUpdate(withList dictionary: NSDictionary, in context: NSManagedObjectContext) -> [Scale_Item] {
        var scaleItems = [Scale_Item]()
        for dicForOneItem in dictionary.allValues {
            if let dicForOneItem = dicForOneItem as? NSDictionary {
                if let scaleItem = Scale_Item.createOrUpdate(matchDictionary: dicForOneItem, in: context) {
                    scaleItems.append(scaleItem)
                }
            }
        }
        return scaleItems
    }
    var dictionaryValue: [String: Any] {
        get {
            return [
                "identifier": identifier ?? "",
                "status": status ?? "",
                "start": start?.timeIntervalSince1970.bitPattern.description ?? ""
            ]
        }
    }
    class var rootFirebaseDatabaseReference: String {
        get {
            return "scales"
        }
    }
}

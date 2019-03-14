//
//  Invitation_Item.swift
//  Eia
//
//  Created by Cleofas Pereira on 05/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

class Invitation_Item: NSManagedObject {
    class func find(matching identifier: String, in context: NSManagedObjectContext) -> Invitation_Item? {
        let request: NSFetchRequest<Invitation_Item> = Invitation_Item.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", identifier)
        if let matches = try? context.fetch(request) {
            if matches.count > 0 {
                return matches.first
            }
        }
        return nil
    }
    class func create(withInvitation invitation: Invitation, in context: NSManagedObjectContext) -> Invitation_Item {
        let invitationItem = Invitation_Item(context: context)
        invitationItem.identifier = invitation.identifier
        invitationItem.status = invitation.status
        invitationItem.scale_id = invitation.scale_id
        invitationItem.voluntary_id = invitation.voluntary_id
        return invitationItem
    }
    class func create(withDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Invitation_Item? {
        let invitationItem = Invitation_Item(context: context)
        if let identifier = dictionary["identifier"] as? String {
            invitationItem.identifier = identifier
        } else {return nil}
        if let status = dictionary["status"] as? String {
            invitationItem.status = status
        } else {return nil}
        if let scaleId = dictionary["scale_id"] as? String {
            invitationItem.scale_id = scaleId
        } else {return nil}
        if let voluntaryId = dictionary["voluntary_id"] as? String {
            invitationItem.voluntary_id = voluntaryId
        } else {return nil}
        return invitationItem
    }
    class func createOrUpdate(matchDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Invitation_Item? {
        var invitationItem: Invitation_Item? = nil
        if let identifier = dictionary["identifier"] as? String {
            invitationItem = Invitation_Item.find(matching: identifier, in: context)
            if let invitationItem = invitationItem {
                if let status = dictionary["status"] as? String {
                    invitationItem.status = status
                }
                if let scaleId = dictionary["scale_id"] as? String {
                    invitationItem.scale_id = scaleId
                }
                if let voluntaryId = dictionary["voluntary_id"] as? String {
                    invitationItem.voluntary_id = voluntaryId
                }
            } else {
                invitationItem = Invitation_Item.create(withDictionary: dictionary, in: context)
            }
        }
        return invitationItem
    }
    class func createOrUpdate(withList dictionary: NSDictionary, in context: NSManagedObjectContext) -> [Invitation_Item] {
        var invitationItems = [Invitation_Item]()
        for dicForOneItem in dictionary.allValues {
            if let dicForOneItem = dicForOneItem as? NSDictionary {
                if let invitationItem = Invitation_Item.createOrUpdate(matchDictionary: dicForOneItem, in: context) {
                    invitationItems.append(invitationItem)
                }
            }
        }
        return invitationItems
    }
    var dictionaryValue: [String: Any] {
        get {
            return [
                "identifier": identifier ?? "",
                "status": status ?? "",
                "scale_id": scale_id ?? "",
                "voluntary_id": voluntary_id ?? ""
            ]
        }
    }
    class var rootFirebaseDatabaseReference: String {
        get {
            return "invitations"
        }
    }
}

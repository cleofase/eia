//
//  Scale.swift
//  Eia
//
//  Created by Cleofas Pereira on 05/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

enum ScaleStatus: String {
    case created = "CRIADA"
    case confirmed = "CONFIRMADA"
    case done = "CONCLUIDA"
    case canceled = "CANCELADA"
    var stringValue: String {get{
        return self.rawValue
        }}
}
class Scale: NSManagedObject {
    class func find(matching identifier: String, in context: NSManagedObjectContext) -> Scale? {
        let request: NSFetchRequest<Scale> = Scale.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", identifier)
        if let matches = try? context.fetch(request) {
            if matches.count > 0 {
                return matches.first
            }
        }
        return nil
    }
    class func create(withStarting start: Date, end: Date, at team: Team, in context: NSManagedObjectContext) -> Scale {
        let scale = Scale(context: context)
        scale.identifier = UUID().uuidString
        scale.start = start
        scale.end = end
        scale.leader_id = team.leader_id
        scale.leader_name = team.leader_name
        scale.team_id = team.identifier
        scale.team_name = team.name
        scale.status = ScaleStatus.created.stringValue
        return scale
    }
    class func create(withDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Scale? {
        let scale = Scale(context: context)
        if let identifier = dictionary["identifier"] as? String {
            scale.identifier = identifier
        } else {return nil}
        if let strStart = dictionary["start"] as? String {
            if let startAsInterval = UInt64(strStart) {
                scale.start = Date(timeIntervalSince1970: TimeInterval(bitPattern: startAsInterval))
            } else {return nil}
        } else {return nil}
        if let strEnd = dictionary["end"] as? String {
            if let endAsInterval = UInt64(strEnd) {
                scale.end = Date(timeIntervalSince1970: TimeInterval(bitPattern: endAsInterval))
            } else {return nil}
        } else {return nil}
        if let leader_id = dictionary["leader_id"] as? String {
            scale.leader_id = leader_id
        } else {return nil}
        if let leader_name = dictionary["leader_name"] as? String {
            scale.leader_name = leader_name
        } else {return nil}
        if let team_id = dictionary["team_id"] as? String {
            scale.team_id = team_id
        } else {return nil}
        if let team_name = dictionary["team_name"] as? String {
            scale.team_name = team_name
        } else {return nil}
        if let status = dictionary["status"] as? String {
            scale.status = status
        } else {return nil}
        if let invitations = dictionary["invitations"] as? NSDictionary {
            scale.invitations = NSSet(array: Invitation_Item.createOrUpdate(withList: invitations, in: context))
        }
        return scale
    }
    class func createOrUpdate(matchDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Scale? {
        var scale: Scale? = nil
        if let identifier = dictionary["identifier"] as? String {
            scale = Scale.find(matching: identifier, in: context)
            if let scale = scale {
                if let strStart = dictionary["start"] as? String {
                    if let startAsInterval = UInt64(strStart) {
                        scale.start = Date(timeIntervalSince1970: TimeInterval(bitPattern: startAsInterval))
                    } else {return nil}
                } else {return nil}
                if let strEnd = dictionary["end"] as? String {
                    if let endAsInterval = UInt64(strEnd) {
                        scale.end = Date(timeIntervalSince1970: TimeInterval(bitPattern: endAsInterval))
                    } else {return nil}
                } else {return nil}
                if let leader_id = dictionary["leader_id"] as? String {
                    scale.leader_id = leader_id
                } else {return nil}
                if let leader_name = dictionary["leader_name"] as? String {
                    scale.leader_name = leader_name
                } else {return nil}
                if let team_id = dictionary["team_id"] as? String {
                    scale.team_id = team_id
                } else {return nil}
                if let team_name = dictionary["team_name"] as? String {
                    scale.team_name = team_name
                } else {return nil}
                if let status = dictionary["status"] as? String {
                    scale.status = status
                } else {return nil}
                if let invitations = dictionary["invitations"] as? NSDictionary {
                    scale.invitations = NSSet(array: Invitation_Item.createOrUpdate(withList: invitations, in: context))
                }
            } else {
                scale = Scale.create(withDictionary: dictionary, in: context)
            }
        }
        return scale
    }
    private func dictionaryValueForInvitations() -> [String: Any] {
        var dictionary = [String: Any]()
        if let invitations = invitations {
            for invitation in invitations {
                if let invitation = invitation as? Invitation_Item, let identifier = invitation.identifier {
                    dictionary.updateValue(invitation.dictionaryValue, forKey: identifier)
                }
            }
        }
        return dictionary
    }
    var dictionaryValue: [String: Any] {
        get {
            return [
                "identifier": identifier ?? "",
                "start": start?.timeIntervalSince1970.bitPattern.description ?? "",
                "end": end?.timeIntervalSince1970.bitPattern.description ?? "",
                "leader_id": leader_id ?? "",
                "leader_name": leader_name ?? "",
                "team_id": team_id ?? "",
                "team_name": team_name ?? "",
                "status": status ?? "",
                "invitations": dictionaryValueForInvitations()
            ]
        }
    }
    class var rootFirebaseDatabaseReference: String {
        get {
            return "scale"
        }
    }
}

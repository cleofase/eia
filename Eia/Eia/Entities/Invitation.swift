//
//  Invitation.swift
//  Eia
//
//  Created by Cleofas Pereira on 05/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

enum InvitationStatus: String {
    case created = "CRIADO"
    case accepted = "ACEITO"
    case refused = "RECUSADO"
    case canceled = "CANCELADO"
    var stringValue: String {get{
        return self.rawValue
        }}
}
enum InvitationAttendance: String {
    case present = "PRESENTE"
    case absent = "AUSENTE"
    case undefined = "INDEFINIDO"
    var stringValue: String {
        get {
            return self.rawValue
        }
    }
}
class Invitation: NSManagedObject {
    class func find(matching identifier: String, in context: NSManagedObjectContext) -> Invitation? {
        let request: NSFetchRequest<Invitation> = Invitation.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", identifier)
        if let matches = try? context.fetch(request) {
            if matches.count > 0 {
                return matches.first
            }
        }
        return nil
    }
    class func create(withVoluntaryItem voluntaryItem: Voluntary_Item, scaleItem: Scale_Item, in context: NSManagedObjectContext) -> Invitation {
        let invitation = Invitation(context: context)
        invitation.identifier = UUID().uuidString
        invitation.status = InvitationStatus.created.stringValue
        invitation.attendance = InvitationAttendance.undefined.stringValue
        invitation.scale_id = scaleItem.identifier
        invitation.voluntary_id = voluntaryItem.identifier
        invitation.voluntary_name = voluntaryItem.name
        invitation.scale = scaleItem
        invitation.voluntary = voluntaryItem
        return invitation
    }
    var dictionaryValue: [String: Any] {
        get {
            return [
                "identifier": identifier ?? "",
                "scale_id": scale_id ?? "",
                "voluntary_id": voluntary_id ?? "",
                "voluntary_name": voluntary_name ?? "",
                "status": status ?? "",
                "attendance": attendance ?? ""
            ]
        }
    }
    class var rootFirebaseDatabaseReference: String {
        get {
            return "invitation"
        }
    }
}

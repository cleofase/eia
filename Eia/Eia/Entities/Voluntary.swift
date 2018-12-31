//
//  Voluntary.swift
//  Eia
//
//  Created by Cleofas Pereira on 26/12/18.
//  Copyright © 2018 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth

enum VoluntaryStatus: String {
    case pending = "PENDING"
    case active = "ACTIVE"
    case inactive = "INACTIVE"
    var stringValue: String {get{
        return self.rawValue
        }}
}

class Voluntary: NSManagedObject {
    class func find(matching email: String, in context: NSManagedObjectContext) -> Voluntary? {
        let request: NSFetchRequest<Voluntary> = Voluntary.fetchRequest()
        request.predicate = NSPredicate(format: "email = %@", email)
        if let matches = try? context.fetch(request) {
            if matches.count > 0 {
                return matches.first
            }
        }
        return nil
    }
    class func create(with firebaseUser: User, name: String, in context: NSManagedObjectContext) -> Voluntary {
        let voluntary = Voluntary(context: context)
        voluntary.identifier = UUID().uuidString
        voluntary.authId = firebaseUser.uid
        voluntary.name = name
        voluntary.email = firebaseUser.email ?? ""
        voluntary.status = VoluntaryStatus.pending.stringValue
        return voluntary
    }
    class func create(withDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Voluntary? {
        let voluntary = Voluntary(context: context)
        if let name = dictionary["name"] as? String {
            voluntary.name = name
        } else {return nil}
        if let email = dictionary["email"] as? String {
            voluntary.email = email
        } else {return nil}
        if let identifier = dictionary["identifier"] as? String {
            voluntary.identifier = identifier
        } else {return nil}
        if let authId = dictionary["authId"] as? String {
            voluntary.authId = authId
        } else {return nil}
        if let status = dictionary["status"] as? String {
            voluntary.status = status
        } else {return nil}
        if let phone = dictionary["phone"] as? String {
            voluntary.phone = phone
        }
        if let photo_str = dictionary["photo_str"] as? String {
            voluntary.photo_str = photo_str
        }
        if let photo_url = dictionary["photo_url"] as? String {
            voluntary.photo_url = photo_url
        }
        return voluntary
    }
    class func createOrUpdate(matchDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Voluntary? {
        var voluntary: Voluntary? = nil
        if let email = dictionary["email"] as? String {
            voluntary = Voluntary.find(matching: email, in: context)
            if let voluntary = voluntary {
                if let name = dictionary["name"] as? String {
                    voluntary.name = name
                }
                if let status = dictionary["status"] as? String {
                    voluntary.status = status
                }
                if let phone = dictionary["phone"] as? String {
                    voluntary.phone = phone
                }
                if let photo_str = dictionary["photo_str"] as? String {
                    voluntary.photo_str = photo_str
                }
                if let photo_url = dictionary["photo_url"] as? String {
                    voluntary.photo_url = photo_url
                }
            } else {
                voluntary = Voluntary.create(withDictionary: dictionary, in: context)
            }
        }
        return voluntary
    }
    var dictionaryValue: [String: Any] {
        get {
            return [
                "identifier": identifier ?? "",
                "name": name ?? "",
                "email": email ?? "",
                "phone": phone ?? "",
                "photo_str": photo_str ?? "",
                "photo_url": photo_url ?? "",
                "status": status ?? "",
                "authId": authId ?? ""
            ]            
        }
    }
    class var rootFirebaseDatabaseReference: String {
        get {
            return "voluntary"
        }
    }
}

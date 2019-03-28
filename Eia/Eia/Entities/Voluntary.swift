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
    public func findInvitationItem(withInvitationId invitationId: String, in context: NSManagedObjectContext) -> Invitation_Item? {
        let wantedInvitationItem = invitations?.first(where: {(item) in
            if let invitationItem = item as? Invitation_Item {
                if invitationItem.identifier == invitationId {
                    return true
                }
            }
            return false
        })
        return wantedInvitationItem as? Invitation_Item
    }
    public func findGroupItem(withGroupId groupId: String, in context: NSManagedObjectContext) -> Group_Item? {
        let wantedGroupItem = groups?.first(where: {(item) in
            if let groupItem = item as? Group_Item {
                if groupItem.identifier == groupId {
                    return true
                }
            }
            return false
        })
        return wantedGroupItem as? Group_Item
    }
    public func findTeamItem(withTeamId teamId: String, in context: NSManagedObjectContext) -> Team_Item? {
        let wantedTeamItem = teams?.first(where: {(item) in
            if let teamItem = item as? Team_Item {
                if teamItem.identifier == teamId {
                    return true
                }
            }
            return false
        })
        return wantedTeamItem as? Team_Item
    }
    class func find(matching authId: String, in context: NSManagedObjectContext) -> Voluntary? {
        let request: NSFetchRequest<Voluntary> = Voluntary.fetchRequest()
        request.predicate = NSPredicate(format: "authId = %@", authId)
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
        if let groups = dictionary["groups"] as? NSDictionary {
            voluntary.groups = NSSet(array: Group_Item.createOrUpdate(withList: groups, in: context))
        }
        if let teams = dictionary["teams"] as? NSDictionary {
            voluntary.teams = NSSet(array: Team_Item.createOrUpdate(withList: teams, in: context))
        }
        if let invitations = dictionary["invitations"] as? NSDictionary {
            voluntary.invitations = NSSet(array: Invitation_Item.createOrUpdate(withList: invitations, in: context))
        }
        if let scales = dictionary["scales"] as? NSDictionary {
            voluntary.scales = NSSet(array: Scale_Item.createOrUpdate(withList: scales, in: context))
        }
        if let notices = dictionary["notices"] as? NSDictionary {
            voluntary.notices = NSSet(array: Notice.createOrUpdate(withList: notices, in: context))
        }
        return voluntary
    }
    class func createOrUpdate(matchDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Voluntary? {
        var voluntary: Voluntary? = nil
        if let volunteerId = dictionary["authId"] as? String {
            voluntary = Voluntary.find(matching: volunteerId, in: context)
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
                if let groups = dictionary["groups"] as? NSDictionary {
                    voluntary.groups = NSSet(array: Group_Item.createOrUpdate(withList: groups, in: context))
                }
                if let teams = dictionary["teams"] as? NSDictionary {
                    voluntary.teams = NSSet(array: Team_Item.createOrUpdate(withList: teams, in: context))
                }
                if let invitations = dictionary["invitations"] as? NSDictionary {
                    voluntary.invitations = NSSet(array: Invitation_Item.createOrUpdate(withList: invitations, in: context))
                }
                if let scales = dictionary["scales"] as? NSDictionary {
                    voluntary.scales = NSSet(array: Scale_Item.createOrUpdate(withList: scales, in: context))
                }
                if let notices = dictionary["notices"] as? NSDictionary {
                    voluntary.notices = NSSet(array: Notice.createOrUpdate(withList: notices, in: context))
                }
            } else {
                voluntary = Voluntary.create(withDictionary: dictionary, in: context)
            }
        }
        return voluntary
    }
    private func dictionaryValueForGroups() -> [String: Any] {
        var dictionary = [String: Any]()
        if let groups = groups {
            for group in groups {
                if let group = group as? Group_Item, let identifier = group.identifier {
                    dictionary.updateValue(group.dictionaryValue, forKey: identifier)
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
    private func dictionaryValueForNotices() -> [String: Any] {
        var dictionary = [String: Any]()
        if let notices = notices {
            for notice in notices {
                if let notice = notice as? Notice, let identifier = notice.identifier {
                    dictionary.updateValue(notice.dictionaryValue, forKey: identifier)
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
                "email": email ?? "",
                "phone": phone ?? "",
                "photo_str": photo_str ?? "",
                "photo_url": photo_url ?? "",
                "status": status ?? "",
                "authId": authId ?? "",
                "groups": dictionaryValueForGroups(),
                "teams": dictionaryValueForTeams(),
                "invitations": dictionaryValueForInvitations(),
                "scales": dictionaryValueForScales(),
                "notices": dictionaryValueForNotices()
            ]            
        }
    }
    class var rootFirebaseDatabaseReference: String {
        get {
            return "voluntary"
        }
    }
}

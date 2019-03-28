//
//  Notice.swift
//  Eia
//
//  Created by Cleofas Pereira on 23/03/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

public enum NoticeRelatedEntityName: String {
    case group = "GROUP"
    case team = "TEAM"
    case scale = "SCALE"
    
    var stringValue: String {
        get {
            return self.rawValue
        }
    }
}
public enum NoticeStatus: String {
    case read = "LIDA"
    case unread = "NÃO LIDA"
    var stringValue: String {
        get {
            return self.rawValue
        }
    }
}
enum NoticeType: String {
    case joinGroup = "JOIN_GROUP"
    case joinTeam = "JOIN_TEAM"
    case newScale = "NEW_SCALE"
    case confirmedScale = "CONFIRMED_SCALE"
    case updateScale = "UPDATE_SCALE"
    case cancelScale = "CANCEL_SCALE"
    case doneScale = "DONE_SCALE"
    case exchangeRequest = "EXCHANGE_REQUEST"
    var stringValue: String {
        get {
            return self.rawValue
        }
    }
    var title: String {
        get {
            return NSLocalizedString(self.rawValue + "_NOTICE_TYPE", comment: "")
        }
    }
    var contentTemplate: String {
        get {
            return NSLocalizedString(self.rawValue + "_NOTICE_CONTENT", comment: "")
        }
    }
    var relatedEntity: String {
        get {
            switch self {
            case .joinGroup:
                return NoticeRelatedEntityName.group.stringValue
            case .joinTeam:
                return NoticeRelatedEntityName.team.stringValue
            case .newScale, .updateScale, .confirmedScale, .doneScale, .cancelScale, .exchangeRequest:
                return NoticeRelatedEntityName.scale.stringValue
            }
        }
    }
    var icon: UIImage? {
        get {
            switch self {
            case .joinGroup:
                return UIImage(named: "group_selected_tab_icon")
            case .joinTeam:
                return UIImage(named: "team_selected_tab_icon")
            case .newScale, .updateScale, .confirmedScale, .doneScale, .cancelScale, .exchangeRequest:
                return UIImage(named: "schedule_selected_tab_icon")
            }
        }
    }
}
class Notice: NSManagedObject {
    class func find(matching identifier: String, in context: NSManagedObjectContext) -> Notice? {
        let request: NSFetchRequest<Notice> = Notice.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", identifier)
        if let matches = try? context.fetch(request) {
            if matches.count > 0 {
                return matches.first
            }
        }
        return nil
    }
    class func find(withVoluntaryId voluntaryId: String, in context: NSManagedObjectContext) -> Notice? {
        let request: NSFetchRequest<Notice> = Notice.fetchRequest()
        request.predicate = NSPredicate(format: "voluntary_id = %@", voluntaryId)
        if let matches = try? context.fetch(request) {
            if matches.count > 0 {
                return matches.first
            }
        }
        return nil
    }
    class func create(withType noticeType: NoticeType, relatedEntity entity: NSManagedObject, voluntaryId: String, in context: NSManagedObjectContext) -> Notice? {
        let notice = Notice(context: context)
        notice.identifier = UUID().uuidString
        notice.notice_type = noticeType.stringValue
        notice.voluntary_id = voluntaryId
        notice.status = NoticeStatus.unread.stringValue
        notice.date = Date()
        notice.title = noticeType.title
        notice.related_entity = noticeType.relatedEntity
        switch noticeType.relatedEntity {
        case NoticeRelatedEntityName.group.stringValue:
            if let group = entity as? Group {
                notice.entity_id = group.identifier
                let groupName = group.name ?? ""
                notice.notice_content = String(format: noticeType.contentTemplate, groupName)
            } else {
                return nil
            }
        case NoticeRelatedEntityName.team.stringValue:
            if let team = entity as? Team {
                notice.entity_id = team.identifier
                let teamName = team.name ?? ""
                notice.notice_content = String(format: noticeType.contentTemplate, teamName)
            } else {
                return nil
            }
        case NoticeRelatedEntityName.scale.stringValue:
            if let scale = entity as? Scale {
                notice.entity_id = scale.identifier
                let scaleStartDate = scale.start?.dateStringValue ?? ""
                let scaleTeamName = scale.team_name ?? ""
                notice.notice_content = String(format: noticeType.contentTemplate, scaleStartDate, scaleTeamName)
            } else {
                return nil
            }
        default:
            return nil
        }
        return notice
    }
    class func create(withDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Notice? {
        let notice = Notice(context: context)
        if let identifier = dictionary["identifier"] as? String {
            notice.identifier = identifier
        } else {return nil}
        if let notice_type = dictionary["notice_type"] as? String {
            notice.notice_type = notice_type
        } else {return nil}
        if let voluntary_id = dictionary["voluntary_id"] as? String {
            notice.voluntary_id = voluntary_id
        } else {return nil}
        if let strDate = dictionary["date"] as? String {
            if let dateAsInterval = UInt64(strDate) {
                notice.date = Date(timeIntervalSince1970: TimeInterval(bitPattern: dateAsInterval))
            } else {return nil}
        } else {return nil}
        if let related_entity = dictionary["related_entity"] as? String {
            notice.related_entity = related_entity
        } else {return nil}
        if let entity_id = dictionary["entity_id"] as? String {
            notice.entity_id = entity_id
        } else {return nil}
        if let title = dictionary["title"] as? String {
            notice.title = title
        } else {return nil}
        if let notice_content = dictionary["notice_content"] as? String {
            notice.notice_content = notice_content
        } else {return nil}
        if let status = dictionary["status"] as? String {
            notice.status = status
        } else {return nil}
        return notice
    }
    class func createOrUpdate(matchDictionary dictionary: NSDictionary, in context: NSManagedObjectContext) -> Notice? {
        var notice: Notice? = nil
        if let identifier = dictionary["identifier"] as? String {
            notice = Notice.find(matching: identifier, in: context)
            if let notice = notice {
                if let notice_type = dictionary["notice_type"] as? String {
                    notice.notice_type = notice_type
                }
                if let voluntary_id = dictionary["voluntary_id"] as? String {
                    notice.voluntary_id = voluntary_id
                }
                if let strDate = dictionary["date"] as? String {
                    if let dateAsInterval = UInt64(strDate) {
                        notice.date = Date(timeIntervalSince1970: TimeInterval(bitPattern: dateAsInterval))
                    }
                }
                if let related_entity = dictionary["related_entity"] as? String {
                    notice.related_entity = related_entity
                }
                if let entity_id = dictionary["entity_id"] as? String {
                    notice.entity_id = entity_id
                }
                if let title = dictionary["title"] as? String {
                    notice.title = title
                }
                if let notice_content = dictionary["notice_content"] as? String {
                    notice.notice_content = notice_content
                }
                if let status = dictionary["status"] as? String {
                    notice.status = status
                }
            } else {
                notice = Notice.create(withDictionary: dictionary, in: context)
            }
        }
        return notice
    }
    class func createOrUpdate(withList dictionary: NSDictionary, in context: NSManagedObjectContext) -> [Notice] {
        var notices = [Notice]()
        for dicForOneItem in dictionary.allValues {
            if let dicForOneItem = dicForOneItem as? NSDictionary {
                if let notice = Notice.createOrUpdate(matchDictionary: dicForOneItem, in: context) {
                    notices.append(notice)
                }
            }
        }
        return notices
    }
    var dictionaryValue: [String: Any] {
        get {
            return [
                "identifier": identifier ?? "",
                "notice_typenotice_type": notice_type ?? "",
                "voluntary_id": voluntary_id ?? "",
                "related_entity": related_entity ?? "",
                "entity_id": entity_id ?? "",
                "title": title ?? "",
                "notice_content": notice_content ?? "",
                "status": status ?? ""
            ]
        }
    }
    class var rootFirebaseDatabaseReference: String {
        get {
            return "notices"
        }
    }
}

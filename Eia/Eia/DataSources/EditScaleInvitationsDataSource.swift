//
//  EditScaleInvitationsDataSource.swift
//  Eia
//
//  Created by Cleofas Pereira on 27/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class EditScaleInvitationsDataSource: NSObject {
    private let context: NSManagedObjectContext
    private let scale: Scale
    private var scaleInvitationItems = [Invitation_Item]()
    private let fbDbRef = Database.database().reference()
    
    init(withScale scale: Scale, context: NSManagedObjectContext) {
        self.scale = scale
        self.context = context
        self.scaleInvitationItems = scale.invitations?.allObjects as? [Invitation_Item] ?? [Invitation_Item]()
    }
}

extension EditScaleInvitationsDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scaleInvitationItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editScaleInvitationCell", for: indexPath)
        if let cell = cell as? ScaleInvitationTableViewCell {
            cell.setup(withInvitationItem: scaleInvitationItems[indexPath.row])
            return cell
        }
        return cell
    }
}

//
//  ScaleInvitationTableViewCell.swift
//  Eia
//
//  Created by Cleofas Pereira on 15/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class ScaleInvitationTableViewCell: UITableViewCell {
    private let fbDbRef = Database.database().reference()
    private let container = AppDelegate.persistentContainer!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
        photoImageView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    public func setup(withInvitationItem invitationItem: Invitation_Item) {
        let context = container.viewContext
        let invitationId = invitationItem.identifier ?? ""
        if let invitation = Invitation.find(matching: invitationId, in: context) {
            setup(withInvitation: invitation)
        }
        updateInvitationFromCloud(withInvitationId: invitationId)
    }
    private func setup(withInvitation invitation: Invitation) {
        let context = container.viewContext
        nameLabel.text = invitation.voluntary_name
        statusLabel.text = invitation.status
        let status = invitation.status ?? ""
        if status != InvitationStatus.accepted.stringValue {
            statusImageView.isHidden = true
        } else {
            statusImageView.isHidden = false
        }
        let voluntaryId = invitation.voluntary_id ?? ""
        if let voluntary = Voluntary.find(matching: voluntaryId, in: context) {
            setupVoluntaryPhoto(withVoluntary: voluntary)
        }
        updateVoluntaryFromCloud(withVoluntaryId: voluntaryId)
    }
    private func setupVoluntaryPhoto(withVoluntary voluntary: Voluntary) {
        if let photoStr = voluntary.photo_str, let photoData = Data(base64Encoded: photoStr), let photoImage = UIImage(data: photoData) {
            photoImageView.image = photoImage
        } else {
            photoImageView.image = nil
            // photo default...
        }
    }
    private func updateInvitationFromCloud(withInvitationId invitationId: String) {
        let context = container.viewContext
        fbDbRef.child(Invitation.rootFirebaseDatabaseReference).child(invitationId).observeSingleEvent(of: .value, with: {[weak self](snapshot) in
            if let invitationDic = snapshot.value as? NSDictionary {
                if let invitation = Invitation.createOrUpdate(matchDictionary: invitationDic, in: context) {
                    DispatchQueue.main.async {[weak self] in
                        self?.setup(withInvitation: invitation)
                    }
                }
            }
        })
    }
    private func updateVoluntaryFromCloud(withVoluntaryId voluntaryId: String) {
        let context = container.viewContext
        fbDbRef.child(Voluntary.rootFirebaseDatabaseReference).child(voluntaryId).observeSingleEvent(of: .value, with: {[weak self](snapshot) in
            if let voluntaryDic = snapshot.value as? NSDictionary {
                if let voluntary = Voluntary.createOrUpdate(matchDictionary: voluntaryDic, in: context) {
                    DispatchQueue.main.async {[weak self] in
                        self?.setupVoluntaryPhoto(withVoluntary: voluntary)
                    }
                }
            }
        })
    }
}

//
//  RequestExchangeTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 06/03/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

class RequestExchangeTableViewController: EiaFormTableViewController {
    // MARK: - Public vars
    public var scale: Scale?
    
    // MARK: - Private vars
    private var voluntary: Voluntary?
    private var container: NSPersistentContainer = AppDelegate.persistentContainer!
    private let fbDBRef = Database.database().reference()
    private var volunteersDataSource: RequestExchangeVolunteersDataSource!
    
    // MARK: - Outlets
    @IBOutlet weak var teamNameTextField: TeamNameTextField!
    @IBOutlet weak var alertTeamNameLabel: UILabel!
    @IBOutlet weak var scaleStatusTextField: ScaleStatusTextField!
    @IBOutlet weak var alertScaleStatusLabel: UILabel!
    @IBOutlet weak var startScaleTextField: BeginScaleTextField!
    @IBOutlet weak var alertStartScaleLabel: UILabel!
    @IBOutlet weak var endScaleTextField: EndScaleTextField!
    @IBOutlet weak var alertEndScaleLabel: UILabel!
    @IBOutlet weak var volunteersTableView: UITableView!
    @IBOutlet weak var alertVolunteersLabel: UILabel!
    
    // MARK: - Actions
    @IBAction func confirmButton(_ sender: UIBarButtonItem) {
        if let substituteVoluntaryItem = validateSubstituteSelection() {
            performExchangeRequestWithExit(withSubstitute: substituteVoluntaryItem)
        } else {
            volunteersTableView.becomeFirstResponder()
        }
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerFieldsToDinamicValidation()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deRegisterFieldsToDinamicValidation()
    }
    
    // MARK: - UI Funcs
    private func setupUI() {
        guard let scale = scale else {return}
        let context = container.viewContext
        teamNameTextField.isEnabled = false
        scaleStatusTextField.isEnabled = false
        startScaleTextField.isEnabled = false
        endScaleTextField.isEnabled = false
        volunteersDataSource = RequestExchangeVolunteersDataSource(withScale: scale, context: context)
        volunteersTableView.dataSource = volunteersDataSource
        volunteersTableView.delegate = volunteersDataSource
        volunteersTableView.tableFooterView = UIView()
    }
    private func updateUI() {
        guard let scale = scale else {return}
        teamNameTextField.text = scale.team_name
        alertTeamNameLabel.text?.removeAll()
        scaleStatusTextField.text = scale.status
        alertScaleStatusLabel.text?.removeAll()
        startScaleTextField.date = scale.start
        alertStartScaleLabel.text?.removeAll()
        endScaleTextField.date = scale.end
        alertEndScaleLabel.text?.removeAll()
        volunteersTableView.reloadData()
        volunteersTableView.setEditing(true, animated: true)
    }
    private func validateSubstituteSelection() -> Voluntary_Item? {
        if let voluntaryItem = volunteersDataSource.selectedVoluntary {
            alertVolunteersLabel.text?.removeAll()
            return voluntaryItem
        } else {
            let substituteVoluntaryError = EiaError(withType: EiaErrorType.substituteNotSelected)
            alertVolunteersLabel.text = substituteVoluntaryError.description
            return nil
        }
    }
    private func performExchangeRequestWithExit(withSubstitute substituteVoluntaryItem: Voluntary_Item) {
        guard let scale = scale else {return}
        let context = container.viewContext
        let scaleId = scale.identifier ?? ""
        let myId = Auth.auth().currentUser?.uid ?? ""
        if let invitationItem = scale.findInvitationItem(withVoluntaryId: myId, in: context) {
            invitationItem.status = InvitationStatus.refused.stringValue
            try? context.save()
            let invitationId = invitationItem.identifier ?? ""
            fbDBRef
                .child(Scale.rootFirebaseDatabaseReference)
                .child(scaleId).child(Invitation_Item.rootFirebaseDatabaseReference)
                .child(invitationId)
                .setValue(invitationItem.dictionaryValue)
            if let voluntary = Voluntary.find(matching: myId, in: context) {
                if let invitationItem = voluntary.findInvitationItem(withInvitationId: invitationId, in: context) {
                    invitationItem.status = InvitationStatus.refused.stringValue
                    try? context.save()
                    fbDBRef
                        .child(Voluntary.rootFirebaseDatabaseReference)
                        .child(myId).child(Invitation_Item.rootFirebaseDatabaseReference)
                        .child(invitationId)
                        .setValue(invitationItem.dictionaryValue)
                }
            }
            if let invitation = Invitation.find(matching: invitationId, in: context) {
                invitation.status = InvitationStatus.refused.stringValue
                try? context.save()
                fbDBRef
                    .child(Invitation.rootFirebaseDatabaseReference)
                    .child(invitationId)
                    .setValue(invitation.dictionaryValue)
            }
        }
        if let scaleItem = Scale_Item.find(matching: scaleId, in: context) {
            let substituteInvitation = Invitation.create(withVoluntaryItem: substituteVoluntaryItem, scaleItem: scaleItem, in: context)
            let substituteInvitationItem = Invitation_Item.create(withInvitation: substituteInvitation, in: context)
            scale.addToInvitations(substituteInvitationItem)
            try? context.save()
            let substituteInvitationId = substituteInvitation.identifier ?? ""
            let substituteVolutaryId = substituteVoluntaryItem.identifier ?? ""
            fbDBRef
                .child(Invitation.rootFirebaseDatabaseReference)
                .child(substituteInvitationId)
                .setValue(substituteInvitation.dictionaryValue)
            fbDBRef
                .child(Scale.rootFirebaseDatabaseReference)
                .child(scaleId)
                .child(Invitation_Item.rootFirebaseDatabaseReference)
                .child(substituteInvitationId)
                .setValue(substituteInvitationItem.dictionaryValue)
            
            
            // Send notices routine...
            if let notice = Notice.create(withType: NoticeType.exchangeRequest, relatedEntity: scale, voluntaryId: substituteVolutaryId, in: context) {
                if let substituteVolutary = Voluntary.find(matching: substituteVolutaryId, in: context) {
                    substituteVolutary.addToInvitations(substituteInvitationItem)
                    substituteVolutary.addToNotices(notice)
                }
                try? context.save()
                let noticeId = notice.identifier ?? ""
                fbDBRef.child(Voluntary.rootFirebaseDatabaseReference).child(substituteVolutaryId).child(Notice.rootFirebaseDatabaseReference).child(noticeId).setValue(notice.dictionaryValue)
            }
            fbDBRef
                .child(Voluntary.rootFirebaseDatabaseReference)
                .child(substituteVolutaryId)
                .child(Invitation_Item.rootFirebaseDatabaseReference)
                .child(substituteInvitationId)
                .setValue(substituteInvitationItem.dictionaryValue)
        }
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.endEditing(true)
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = EiaColors.SunSet
        }
    }
}

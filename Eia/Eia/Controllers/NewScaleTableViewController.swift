//
//  NewScaleTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 03/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class NewScaleTableViewController: EiaFormTableViewController {
    public var team: Team?
    
    private var containter: NSPersistentContainer = AppDelegate.persistentContainer!
    private var volunteersDataSource: NewScaleVolunteersDataSource!
    private let fbDBRef = Database.database().reference()

    @IBOutlet weak var teamNameTextField: TeamNameTextField!
    @IBOutlet weak var alertTeamNameLabel: UILabel!
    @IBOutlet weak var beginScaleTextField: BeginScaleTextField!
    @IBOutlet weak var alertBeginScaleLabel: UILabel!
    @IBOutlet weak var endScaleTextField: EndScaleTextField!
    @IBOutlet weak var alertEndScaleLabel: UILabel!
    @IBOutlet weak var volunteersTableView: UITableView!
    
    @IBAction func confirmButton(_ sender: UIBarButtonItem) {
        guard let team = team else {return}
        performFormValidation(validationDidFinishWithSuccess: {[weak self] (formValid) in
            if formValid {
                let start = self?.beginScaleTextField.date ?? Date()
                let end = self?.endScaleTextField.date ?? Date()
                let volunteers = self?.volunteersDataSource.selectedVolunteerItems ?? [Voluntary_Item]()
                self?.createScaleWithExit(withStarting: start, end: end, volunteerItems: volunteers, at: team)
            } else {
                self?.becomeFirstNotValidFieldFirstResponder()
            }
        })
    }
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
    private func setupUI() {
        guard let team = team else {return}
        let context = containter.viewContext
        teamNameTextField.isEnabled = false
        beginScaleTextField.delegate = self
        endScaleTextField.delegate = self
        endScaleTextField.initialDateTextField = beginScaleTextField
        eiaTextFields = [beginScaleTextField, endScaleTextField]
        alertLabels = [alertBeginScaleLabel, alertEndScaleLabel]
        volunteersTableView.tableFooterView = UIView()
        volunteersDataSource = NewScaleVolunteersDataSource(withTeam: team, context: context)
        volunteersTableView.dataSource = volunteersDataSource
        volunteersTableView.delegate = volunteersDataSource
    }
    private func updateUI() {
        guard let team = team else {return}
        teamNameTextField.text = team.name
        volunteersTableView.reloadData()
        volunteersTableView.setEditing(true, animated: true)
    }
    private func createScaleWithExit(withStarting start: Date, end: Date, volunteerItems: [Voluntary_Item], at team: Team) {
        let context = containter.viewContext
        
        let scale = Scale.create(withStarting: start, end: end, at: team, in: context)
        let scaleItem = Scale_Item.create(withScale: scale, in: context)
        team.addToScales(scaleItem)
        try? context.save()

        for volunteerItem in volunteerItems {
            let invitation = Invitation.create(withVoluntaryItem: volunteerItem, scaleItem: scaleItem, in: context)
            let invitationId = invitation.identifier ?? ""
            let invitationItem = Invitation_Item.create(withInvitation: invitation, in: context)
            scale.addToInvitations(invitationItem)
            let voluntaryId = volunteerItem.identifier ?? ""
            if let voluntary = Voluntary.find(matching: voluntaryId, in: context) {
                voluntary.addToInvitations(invitationItem)
            }
            try? context.save()
            fbDBRef.child(Invitation.rootFirebaseDatabaseReference).child(invitationId).setValue(invitation.dictionaryValue)
            fbDBRef.child(Voluntary.rootFirebaseDatabaseReference).child(voluntaryId).child(Invitation_Item.rootFirebaseDatabaseReference).child(invitationId).setValue(invitationItem.dictionaryValue)
        }
        let scaleId = scale.identifier ?? ""
        fbDBRef.child(Scale.rootFirebaseDatabaseReference).child(scaleId).setValue(scale.dictionaryValue)
        let teamId = team.identifier ?? ""
        fbDBRef.child(Team.rootFirebaseDatabaseReference).child(teamId).child(Scale_Item.rootFirebaseDatabaseReference).child(scaleId).setValue(scaleItem.dictionaryValue)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
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

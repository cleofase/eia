//
//  EditTeamTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 03/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

class EditTeamTableViewController: EiaFormTableViewController {
    // MARK: - Public vars
    public var team: Team?
    
    // MARK: - Private vars
    private var containter: NSPersistentContainer = AppDelegate.persistentContainer!
    private let fbDBRef = Database.database().reference()
    private var volunteersDataSource: EditTeamVolunteersDataSource!
    private var scalesDataSource: EditTeamScalesDataSource!
    
    // MARK: - Outlets
    @IBOutlet weak var groupNameTextField: GroupNameTextField!
    @IBOutlet weak var alertGroupNameLabel: UILabel!
    @IBOutlet weak var leaderNameTextField: UserTextField!
    @IBOutlet weak var alertLeaderNameLabel: UILabel!
    @IBOutlet weak var teamNameTextField: TeamNameTextField!
    @IBOutlet weak var alertTeamNameLabel: UILabel!
    @IBOutlet weak var volunteersTableView: UITableView!
    @IBOutlet weak var scalesTableView: UITableView!
    
    // MARK: - Actions
    @IBAction func confirmButton(_ sender: UIBarButtonItem) {
        performFormValidation(validationDidFinishWithSuccess: {[weak self] (formValid) in
            if formValid {
                let teamName = self?.teamNameTextField.text ?? ""
                let volunteerItems = self?.volunteersDataSource.selectedVolunteerItems ?? [Voluntary_Item]()
                let removedItems = self?.volunteersDataSource.removedVolunteerItems ?? [Voluntary_Item]()
                self?.saveTeamDataWithExit(withName: teamName, volunteerItems: volunteerItems, removedVolunteerItems: removedItems)
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
        let context = containter.viewContext
        guard let team = team else {return}
        groupNameTextField.isEnabled = false
        leaderNameTextField.isEnabled = false
        teamNameTextField.delegate = self
        eiaTextFields = [teamNameTextField]
        alertLabels = [alertTeamNameLabel]
        volunteersTableView.tableFooterView = UIView()
        scalesTableView.tableFooterView = UIView()
        volunteersDataSource = EditTeamVolunteersDataSource(withTeam: team, context: context)
        scalesDataSource = EditTeamScalesDataSource(withTeam: team, context: context)
        volunteersTableView.dataSource = volunteersDataSource
        volunteersTableView.delegate = volunteersDataSource
        scalesTableView.dataSource = scalesDataSource
        scalesTableView.delegate = scalesDataSource
    }
    private func updateUI() {
        guard let team = team else {return}
        groupNameTextField.text = team.group_name
        alertGroupNameLabel.text?.removeAll()
        leaderNameTextField.text = team.leader_name
        alertLeaderNameLabel.text?.removeAll()
        teamNameTextField.text = team.name
        alertTeamNameLabel.text?.removeAll()
        volunteersDataSource.update {[weak self] in
            self?.volunteersTableView.reloadData()
            self?.volunteersTableView.setEditing(true, animated: true)
        }
        volunteersTableView.reloadData()
        scalesTableView.reloadData()
    }
    private func saveTeamDataWithExit(withName name: String, volunteerItems: [Voluntary_Item], removedVolunteerItems: [Voluntary_Item]) {
        let context = containter.viewContext
        guard let team = team else {return}
        team.name = name
        team.volunteers = NSSet(array: volunteerItems)
        try? context.save()
        let teamId = team.identifier ?? ""
        fbDBRef.child(Team.rootFirebaseDatabaseReference).child(teamId).setValue(team.dictionaryValue)
        
        let groupId = team.group_id ?? ""
        if let group = Group.find(matching: groupId, in: context) {
            if let teamItem = group.findTeamItem(withTeamId: teamId, in: context) {
                teamItem.name = name
                try? context.save()
                fbDBRef.child(Group.rootFirebaseDatabaseReference).child(groupId).child(Team_Item.rootFirebaseDatabaseReference).child(teamId).setValue(teamItem.dictionaryValue)
            }
        }
        let leaderId = team.leader_id ?? ""
        if let leader = Voluntary.find(matching: leaderId , in: context) {
            if let teamItem = leader.findTeamItem(withTeamId: teamId, in: context) {
                teamItem.name = name
                try? context.save()
                fbDBRef.child(Voluntary.rootFirebaseDatabaseReference).child(leaderId).child(Team_Item.rootFirebaseDatabaseReference).child(teamId).setValue(teamItem.dictionaryValue)
            }
        }
        for voluntaryItem in volunteerItems {
            let voluntaryId = voluntaryItem.identifier ?? ""
            if let voluntary = Voluntary.find(matching: voluntaryId, in: context) {
                if let teamItem = voluntary.findTeamItem(withTeamId: teamId, in: context) {
                    teamItem.name = name
                    try? context.save()
                    fbDBRef.child(Voluntary.rootFirebaseDatabaseReference).child(voluntaryId).child(Team_Item.rootFirebaseDatabaseReference).child(teamId).setValue(teamItem.dictionaryValue)
                }
            }
        }
        
        for voluntaryItem in removedVolunteerItems {
            let voluntaryId = voluntaryItem.identifier ?? ""
            if let voluntary = Voluntary.find(matching: voluntaryId, in: context) {
                if let teamItem = voluntary.findTeamItem(withTeamId: teamId, in: context) {
                    voluntary.removeFromTeams(teamItem)
                    try? context.save()
                    fbDBRef.child(Voluntary.rootFirebaseDatabaseReference).child(voluntaryId).child(Team_Item.rootFirebaseDatabaseReference).child(teamId).removeValue()
                }
            }
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

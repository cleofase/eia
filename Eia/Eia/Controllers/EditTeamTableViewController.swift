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
    private var workingIndicator = WorkingIndicator()
    
    
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
        performFormValidation(validationDidFinishWithSuccess: {(formValid) in
            if formValid {
                DispatchQueue.main.async {[weak self] in
                    guard let strongSelf = self else {return}
                    let teamName = strongSelf.teamNameTextField.text ?? ""
                    let addedItems = strongSelf.volunteersDataSource.addedVolunteerItems
                    let removedItems = strongSelf.volunteersDataSource.removedVolunteerItems
                    let notChangedItems = strongSelf.volunteersDataSource.notChangedVolunteerItems
                    let selectedItems = strongSelf.volunteersDataSource.selectedVolunteerItems
                    self?.saveTeamDataWithExit(withName: teamName, addedVolunteerItems: addedItems, removedVolunteerItems: removedItems, notChangedVolunteerItems: notChangedItems, selectedVolunteerItems: selectedItems)
                }
            } else {
                DispatchQueue.main.async {[weak self] in
                    self?.becomeFirstNotValidFieldFirstResponder()
                }
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
        refreshEntitiesTables()
    }
    private func refreshEntitiesTables() {
        workingIndicator.show(atTable: volunteersTableView)
        volunteersDataSource.update {
            DispatchQueue.main.async {[weak self] in
                self?.volunteersTableView.reloadData()
                self?.volunteersTableView.setEditing(true, animated: true)
                self?.workingIndicator.hide()
            }
        }
        volunteersTableView.reloadData()
        scalesTableView.reloadData()
    }
    private func saveTeamDataWithExit(withName name: String, addedVolunteerItems: [Voluntary_Item], removedVolunteerItems: [Voluntary_Item], notChangedVolunteerItems: [Voluntary_Item], selectedVolunteerItems: [Voluntary_Item]) {
        let context = containter.viewContext
        guard let team = team else {return}
        team.name = name
        team.volunteers = NSSet(array: selectedVolunteerItems)
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
        for voluntaryItem in addedVolunteerItems {
            let voluntaryId = voluntaryItem.identifier ?? ""
            if let voluntary = Voluntary.find(matching: voluntaryId, in: context) {
                let teamItem = Team_Item.create(withTeam: team, in: context)
                voluntary.addToTeams(teamItem)
                try? context.save()
                fbDBRef.child(Voluntary.rootFirebaseDatabaseReference).child(voluntaryId).child(Team_Item.rootFirebaseDatabaseReference).child(teamId).setValue(teamItem.dictionaryValue)
            }
        }
        for voluntaryItem in notChangedVolunteerItems {
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
            if voluntaryId == leaderId {continue}
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
    private enum FormSectionContentType: Int {
        case groupName = 0
        case leaderName = 1
        case teamName = 2
        case volunteers = 3
        case scales = 4
        
        func heightForRow(with team: Team?, in context: NSManagedObjectContext) -> CGFloat {
            switch self {
            case .groupName:
                return 64
            case .leaderName:
                return 64
            case .teamName:
                return 64
            case .volunteers:
                let groupId = team?.group_id ?? ""
                if let group = Group.find(matching: groupId, in: context) {
                    if let numberOfVolunteers = group.volunteers?.count {
                        return CGFloat(44 * numberOfVolunteers + 44)
                    }
                }
                if let numberOfVolunteers = team?.volunteers?.count {
                    return CGFloat(44 * numberOfVolunteers + 44)
                } else {
                    return 44
                }
            case .scales:
                if let numberOfScales = team?.scales?.count {
                    return CGFloat(60 * numberOfScales + 60)
                } else {
                    return 60
                }
            }
        }
    }

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
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        if let contentType = FormSectionContentType(rawValue: section) {
            return contentType.heightForRow(with: team, in: containter.viewContext )
        } else {
            return 40
        }
    }
}

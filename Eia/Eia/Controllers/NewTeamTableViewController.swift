//
//  NewTeamTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 27/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class NewTeamTableViewController: EiaFormTableViewController {
    public var group: Group?
    
    private var containter: NSPersistentContainer = AppDelegate.persistentContainer!
    private var volunteersDataSource: NewTeamVolunteersDataSource!
    private let fbDBRef = Database.database().reference()
    
    @IBOutlet weak var groupNameTextField: GroupNameTextField!
    @IBOutlet weak var teamNameTextField: TeamNameTextField!
    @IBOutlet weak var alertGroupNameLabel: UILabel!
    @IBOutlet weak var alertTeamNameLabel: UILabel!
    @IBOutlet weak var volunteersTableView: UITableView!
    @IBAction func confirmButton(_ sender: UIBarButtonItem) {
        guard let group = group else {return}
        performFormValidation(validationDidFinishWithSuccess: {[weak self] (formValid) in
            if formValid {
                let name = self?.teamNameTextField.text ?? ""
                let volunteers = self?.volunteersDataSource.selectedVolunteerItems ?? [Voluntary_Item]()
                self?.createTeamWithExit(withName: name, volunteerItems: volunteers, at: group)
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
        guard let group = group else {return}
        let context = containter.viewContext
        groupNameTextField.isEnabled = false
        teamNameTextField.delegate = self
        eiaTextFields = [teamNameTextField]
        alertLabels = [alertTeamNameLabel]
        volunteersTableView.tableFooterView = UIView()
        volunteersDataSource = NewTeamVolunteersDataSource(withGroup: group, context: context)
        volunteersTableView.dataSource = volunteersDataSource
        volunteersTableView.delegate = volunteersDataSource
    }
    private func updateUI() {
        guard let group = group else {return}
        groupNameTextField.text = group.name
        volunteersTableView.reloadData()
        volunteersTableView.setEditing(true, animated: true)
    }
    private func createTeamWithExit(withName name: String, volunteerItems: [Voluntary_Item], at group: Group) {
        let context = containter.viewContext
        let team = Team.create(withName: name, group: group, volunteerItems: volunteerItems, in: context)
        try? context.save()
        let teamId = team.identifier ?? ""
        fbDBRef.child(Team.rootFirebaseDatabaseReference).child(teamId).setValue(team.dictionaryValue)
        
        let teamItem = Team_Item.create(withTeam: team, in: context)
        group.addToTeams(teamItem)
        try? context.save()
        let groupId = group.identifier ?? ""
        fbDBRef.child(Group.rootFirebaseDatabaseReference).child(groupId).child(Team_Item.rootFirebaseDatabaseReference).child(teamId).setValue(teamItem.dictionaryValue)
        
        let leaderId = team.leader_id ?? ""
        if let leader = Voluntary.find(matching: leaderId , in: context) {
            leader.addToTeams(teamItem)
            try? context.save()
            fbDBRef.child(Voluntary.rootFirebaseDatabaseReference).child(leaderId).child(Team_Item.rootFirebaseDatabaseReference).child(teamId).setValue(teamItem.dictionaryValue)
        }
        
        for volunteerItem in volunteerItems {
            let voluntaryId = volunteerItem.identifier ?? ""
            if let voluntary = Voluntary.find(matching: voluntaryId, in: context) {
                voluntary.addToTeams(teamItem)
                try? context.save()
                fbDBRef.child(Voluntary.rootFirebaseDatabaseReference).child(voluntaryId).child(Team_Item.rootFirebaseDatabaseReference).child(teamId).setValue(teamItem.dictionaryValue)
                // Send notices routine...
                if let notice = Notice.create(withType: NoticeType.joinTeam, relatedEntity: team, voluntaryId: voluntaryId, in: context) {
                    voluntary.addToNotices(notice)
                    try? context.save()
                    let noticeId = notice.identifier ?? ""
                    fbDBRef.child(Voluntary.rootFirebaseDatabaseReference).child(voluntaryId).child(Notice.rootFirebaseDatabaseReference).child(noticeId).setValue(notice.dictionaryValue)
                }
            }
        }
        // listar para testar as entidades group, team, group_item, team_item, voluntary, voluntary_item...
        print ("\n\n*** O grupo: \(group.name ?? "") tem:")
        print ("\n****** Itens de Equipes: ([Team_Item])")
        if let teams = group.teams?.allObjects as? [Team_Item] {
            for teamItem in teams {
                print ("\n****** \(teamItem.name ?? "")")
            }
        }
        print ("\n****** Items de Voluntarios: ([Voluntary_Item])")
        if let volunteers = group.volunteers?.allObjects as? [Voluntary_Item] {
            for volunteer in volunteers {
                print ("\n****** \(volunteer.name ?? "")")
            }
        }
        
        print ("\n\n*** A equipe: \(team.name ?? "") tem:")
        print ("\n****** Itens de Voluntarios: ([Voluntary_Item])")
        if let volunteers = team.volunteers?.allObjects as? [Voluntary_Item] {
            for volunteer in volunteers {
                print ("\n****** \(volunteer.name ?? "")")
            }
        }
        
        if let groupItem = Group_Item.find(matching: group.identifier ?? "", in: context) {
            print ("\n\n*** O Item do grupo: \(groupItem.name ?? "") tem:")
            print ("\n****** Voluntarios: ([Voluntary])")
            if let volunteers = groupItem.volunteers?.allObjects as? [Voluntary] {
                for volunteer in volunteers {
                    print ("\n****** \(volunteer.name ?? "")")
                }
            }
        }
        
        print ("\n\n*** O Item da equipe: \(teamItem.name ?? "") tem:")
        print ("\n****** Grupo: (Group)")
        print ("\n****** \(teamItem.group?.name ?? "")")
        print ("\n****** Voluntarios: ([Voluntary])")
        if let volunteers = teamItem.volunteers?.allObjects as? [Voluntary] {
            for volunteer in volunteers {
                print ("\n****** \(volunteer.name ?? "")")
            }
        }
        
        for volunteerItem in volunteerItems {
            print ("\n\n*** O Item de voluntario: \(volunteerItem.name ?? "") tem:")
            print ("\n****** Grupos: ([Group]])")
            if let groups = volunteerItem.groups?.allObjects as? [Group] {
                for group in groups {
                    print ("\n****** \(group.name ?? "")")
                }
            }
            print ("\n****** Equipes: ([Team])")
            if let teams = volunteerItem.teams?.allObjects as? [Team] {
                for team in teams {
                    print ("\n****** \(team.name ?? "")")
                }
            }
        }
        
        for volunteerItem in volunteerItems {
            let identifier = volunteerItem.identifier ?? ""
            if let volunteer = Voluntary.find(matching: identifier, in: context) {
                print ("\n\n*** O voluntario: \(volunteer.name ?? "") tem:")
                print ("\n****** Itens de Grupos: ([Group_Item]])")
                if let groupItems = volunteer.groups?.allObjects as? [Group_Item] {
                    for groupItem in groupItems {
                        print ("\n****** \(groupItem.name ?? "")")
                    }
                }
                print ("\n****** Itens de Equipes: ([Team_Item])")
                if let teamItems = volunteer.teams?.allObjects as? [Team_Item] {
                    for teamItem in teamItems {
                        print ("\n****** \(teamItem.name ?? "")")
                    }
                }
            }
        }
        
        //
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
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


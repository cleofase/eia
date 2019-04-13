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
        navigationController?.popViewController(animated: true)
    }
    private enum FormSectionContentType: Int {
        case groupName = 0
        case teamName = 1
        case volunteers = 2
        
        func heightForRow(with group: Group?) -> CGFloat {
            switch self {
            case .teamName:
                return 64
            case .groupName:
                return 64
            case .volunteers:
                if let numberOfVolunteers = group?.volunteers?.count {
                    return CGFloat(44 * numberOfVolunteers + 44)
                } else {
                    return 44
                }
            }
        }
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
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        if let contentType = FormSectionContentType(rawValue: section) {
            return contentType.heightForRow(with: group)
        } else {
            return 40
        }
    }
}


//
//  AddGroupTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 09/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class NewGroupTableViewController: EiaFormTableViewController {
    public var voluntary: Voluntary?
    private var containter: NSPersistentContainer = AppDelegate.persistentContainer!
    private var volunteersDataSource: NewGroupVolunteersDataSource!
    private let fbDBRef = Database.database().reference()
    private var workingIndicator = WorkingIndicator()

    @IBOutlet weak var leaderNameTextField: UserTextField!
    @IBOutlet weak var nameTextField: GroupNameTextField!
    @IBOutlet weak var descriptionTextField: GroupDescriptionTextField!
    @IBOutlet weak var alertLeaderNameLabel: UILabel!
    @IBOutlet weak var alertNameLabel: UILabel!
    @IBOutlet weak var alertDescriptionLabel: UILabel!
    @IBOutlet weak var volunteerTableView: UITableView!
    @IBAction func confirmButton(_ sender: UIBarButtonItem) {
        performFormValidation(validationDidFinishWithSuccess: {[weak self] (formValid) in
            if formValid {
                let name = self?.nameTextField.text ?? ""
                let description = self?.descriptionTextField.text ?? ""
                let volunteers = self?.volunteersDataSource.selectedVolunteers ?? [Voluntary]()
                self?.createGroup(withName: name, description: description, volunteers: volunteers)
                self?.navigationController?.popViewController(animated: true)
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
        leaderNameTextField.delegate = self
        nameTextField.delegate = self
        descriptionTextField.delegate = self
        leaderNameTextField.isEnabled = false
        leaderNameTextField.text = voluntary?.name
        eiaTextFields = [nameTextField, descriptionTextField]
        alertLabels = [alertNameLabel, alertDescriptionLabel]
        let leaderId = voluntary?.authId ?? ""
        volunteerTableView.tableFooterView = UIView()
        volunteersDataSource = NewGroupVolunteersDataSource(withLeaderId: leaderId, context: context)
        volunteerTableView.dataSource = volunteersDataSource
        volunteerTableView.delegate = volunteersDataSource
    }
    private func updateUI() {
        refreshEntitiesTables()
    }
    private func refreshEntitiesTables() {
        workingIndicator.show(atTable: volunteerTableView)
        volunteersDataSource.update {
            DispatchQueue.main.async {[weak self] in
                self?.volunteerTableView.reloadData()
                self?.volunteerTableView.setEditing(true, animated: true)
                self?.workingIndicator.hide()
            }
        }
        volunteerTableView.reloadData()
    }
    private func createGroup(withName name: String, description: String, volunteers: [Voluntary]) {
        guard let voluntary = voluntary else {return}
        let context = containter.viewContext
        let leaderName = voluntary.name ?? ""
        let leaderId = voluntary.authId ?? ""
        if let group = Group.create(withName: name, description: description, leaderName: leaderName, leaderId: leaderId, volunteers: volunteers, in: context) {
            try? context.save()
            let groupId = group.identifier ?? ""
            fbDBRef.child(Group.rootFirebaseDatabaseReference).child(groupId).setValue(group.dictionaryValue)
            let groupItem = Group_Item.create(withGroup: group, in: context)
            voluntary.addToGroups(groupItem)
            try? context.save()
            let groupItemId = groupItem.identifier ?? ""
            fbDBRef.child(Voluntary.rootFirebaseDatabaseReference).child(leaderId).child(Group_Item.rootFirebaseDatabaseReference).child(groupItemId).setValue(groupItem.dictionaryValue)
            for voluntary in volunteers {
                voluntary.addToGroups(groupItem)
                try? context.save()
                let voluntaryId = voluntary.authId ?? ""
                fbDBRef.child(Voluntary.rootFirebaseDatabaseReference).child(voluntaryId).child(Group_Item.rootFirebaseDatabaseReference).child(groupItemId).setValue(groupItem.dictionaryValue)
                // Send notices routine...
                if let notice = Notice.create(withType: NoticeType.joinGroup, relatedEntity: group, voluntaryId: voluntaryId, in: context) {
                    voluntary.addToNotices(notice)
                    try? context.save()
                    let noticeId = notice.identifier ?? ""
                    fbDBRef.child(Voluntary.rootFirebaseDatabaseReference).child(voluntaryId).child(Notice.rootFirebaseDatabaseReference).child(noticeId).setValue(notice.dictionaryValue)
                }
            }
        }
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

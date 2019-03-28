//
//  NoticesTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 24/03/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

class NoticesTableViewController: UITableViewController {
    public var voluntary: Voluntary?
    
    private var notices = [Notice]()
    private var containter: NSPersistentContainer = AppDelegate.persistentContainer!
    private let fbDBRef = Database.database().reference()
    private let workingIndicator = WorkingIndicator()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let context = containter.viewContext
        if let identifier = sender as? String {
            switch segue.identifier {
            case "detailRelatedGroupSegue":
                if let group = Group.find(matching: identifier, in: context), let destination = segue.destination as? DetailGroupTableViewController {
                    destination.group = group
                }
            case "detailRelatedTeamSegue":
                if let team = Team.find(matching: identifier, in: context), let destination = segue.destination as? DetailTeamTableViewController {
                    destination.team = team
                }
            case "detailRelatedScaleSegue":
                if let scale = Scale.find(matching: identifier, in: context), let destination = segue.destination as? DetailScaleTableViewController {
                    destination.scale = scale
                }
            default:
                break
            }
        }
    }
    private func setupUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 132
        tableView.tableFooterView = UIView()
    }
    private func updateUI() {
        let context = containter.viewContext
        let voluntaryId = Auth.auth().currentUser?.uid ?? ""
        workingIndicator.show(at: self.view)
        if let voluntary = Voluntary.find(matching: voluntaryId, in: context) {
            self.voluntary = voluntary
            if let notices = voluntary.notices?.allObjects as? [Notice] {
                self.notices = notices.sorted(by: {($0.date ?? Date()) > ($1.date ?? Date())})
            }
            tableView.reloadData()
        }
        retrieveVoluntaryFromCloud(withVoluntaryId: voluntaryId, completionWithSuccess: {[weak self] (voluntary) in
            DispatchQueue.main.async {[weak self] in
                self?.voluntary = voluntary
                if let notices = voluntary.notices?.allObjects as? [Notice] {
                    self?.notices = notices.sorted(by: {($0.date ?? Date()) > ($1.date ?? Date())})
                }
                self?.tableView.reloadData()
                self?.workingIndicator.hide()
            }
        })
    }
    private func retrieveVoluntaryFromCloud(withVoluntaryId voluntaryId: String, completionWithSuccess: @escaping (Voluntary) -> Void) {
        let context: NSManagedObjectContext = containter.viewContext
        fbDBRef.child(Voluntary.rootFirebaseDatabaseReference).child(voluntaryId).observeSingleEvent(of: .value) {[weak self] (snapshot) in
            if let voluntaryDictionary = snapshot.value as? NSDictionary {
                DispatchQueue.main.async {[weak self] in
                    if let retrievedVoluntary = Voluntary.createOrUpdate(matchDictionary: voluntaryDictionary, in: context) {
                        let status = retrievedVoluntary.status ?? ""
                        if status == VoluntaryStatus.pending.stringValue {
                            retrievedVoluntary.status = VoluntaryStatus.active.stringValue
                            try? context.save()
                            self?.fbDBRef.child(Voluntary.rootFirebaseDatabaseReference).child(voluntaryId).setValue(retrievedVoluntary.dictionaryValue)
                        } else {
                            try? context.save()
                        }
                        completionWithSuccess(retrievedVoluntary)
                    }
                }
            }
        }
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notices.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath)
        if let cell = cell as? NoticeTableViewCell {
            cell.setup(withNotice: notices[indexPath.row])
            return cell
        } else {
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let relatedEntity = notices[indexPath.row].related_entity, let entityId = notices[indexPath.row].entity_id {
            switch relatedEntity {
            case NoticeRelatedEntityName.group.stringValue:
                performSegue(withIdentifier: "detailRelatedGroupSegue", sender: entityId)
            case NoticeRelatedEntityName.team.stringValue:
                performSegue(withIdentifier: "detailRelatedTeamSegue", sender: entityId)
            case NoticeRelatedEntityName.scale.stringValue:
                performSegue(withIdentifier: "detailRelatedScaleSegue", sender: entityId)
            default:
                break
            }
        }
    }
}

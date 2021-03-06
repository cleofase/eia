//
//  GroupsTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 05/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

class GroupsTableViewController: UITableViewController {
    public var voluntary: Voluntary?
    private var groupItems = [Group_Item]()
    private var containter: NSPersistentContainer = AppDelegate.persistentContainer!
    private let fbDBRef = Database.database().reference()

    @IBAction func addGroupButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addGroupSegue", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addGroupSegue" {
            if let destination = segue.destination as? NewGroupTableViewController {
                destination.voluntary = voluntary
            }
        }
        if segue.identifier == "detailGroupSegue" {
            if let destination = segue.destination as? DetailGroupTableViewController, let group = sender as? Group {
                destination.group = group
            }
        }
    }
    private func setupUI() {
        tableView.tableFooterView = UIView()
    }
    @objc private func updateUI() {
        let context = containter.viewContext
        let voluntaryId = Auth.auth().currentUser?.uid ?? ""
        if let voluntary = Voluntary.find(matching: voluntaryId, in: context) {
            self.voluntary = voluntary
            if let groupItems = voluntary.groups?.allObjects as? [Group_Item] {
                self.groupItems = groupItems.sorted(by: {($0.name ?? "") < ($1.name ?? "")})
            }
            tableView.reloadData()
        }
//        retrieveVoluntaryFromCloud(withVoluntaryId: voluntaryId, completionWithSuccess: {[weak self] (voluntary) in
//            DispatchQueue.main.async {[weak self] in
//                self?.voluntary = voluntary
//                if let groupItems = voluntary.groups?.allObjects as? [Group_Item] {
//                    self?.groupItems = groupItems.sorted(by: {($0.name ?? "") < ($1.name ?? "")})
//                }
//                self?.tableView.reloadData()
//            }
//        })
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
        return groupItems.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        if let cell = cell as? GroupTableViewCell {
            cell.setup(withGroupItem: groupItems[indexPath.row])
            return cell
        } else {
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? GroupTableViewCell {
            if let group = cell.group {
                performSegue(withIdentifier: "detailGroupSegue", sender: group)                
            }
        }
    }
}

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

class GroupsTableViewController: UITableViewController {
    public var voluntary: Voluntary?
    private var groups = [Group]()
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
            if let destination = segue.destination as? AddGroupTableViewController {
                destination.voluntary = voluntary
            }
        }
    }
    private func setupUI() {
        tableView.tableFooterView = UIView()
    }
    private func updateUI() {
        let context = containter.viewContext
        guard let voluntary = voluntary else {return}
        groups.removeAll()
        if let groupItemsSet = voluntary.groups {
            if let groupItems = groupItemsSet.allObjects as? [Group_Item] {
                for groupItem in groupItems {
                    let groupId = groupItem.identifier ?? ""
                    if let group = Group.find(matching: groupId , in: context) {
                        groups.append(group)
                    }
                }
            }
        }
        tableView.reloadData()
    }
    private func updateGroupsList(with groupItems: [Group_Item]) {
        let context = containter.viewContext
        groups.removeAll()
        for groupItem in groupItems {
            if let identifier = groupItem.identifier, let group = Group.find(matching: identifier, in: context) {
                groups.append(group)
            }
        }
    }
    private func sincGroupsFromCloud(with groupItems: [Group_Item]) {
        let context = containter.viewContext
        groups.removeAll()
        for groupItem in groupItems {
            if let identifier = groupItem.identifier {
                fbDBRef.child(Group.rootFirebaseDatabaseReference).child(identifier).observeSingleEvent(of: .value) {[weak self] (snapshot) in
                    if let groupDictionary = snapshot.value as? NSDictionary {
                        if let group = Group.createOrUpdate(matchDictionary: groupDictionary, in: context) {
                            try? context.save()
                            self?.groups.append(group)
                            self?.tableView.reloadData() // retirar ao colocar o nsfetchresultcontroller...
                        }
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
        return groups.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        if let cell = cell as? GroupTableViewCell {
            cell.setup(with: groups[indexPath.row])
            return cell
        } else {
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}

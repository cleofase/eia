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
    private func updateUI() {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voluntary?.groups?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        if let cell = cell as? GroupTableViewCell, let groupItems = voluntary?.groups?.allObjects as? [Group_Item] {
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

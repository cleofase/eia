//
//  TeamsTableTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 30/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase

class TeamsTableTableViewController: UITableViewController {
    public var voluntary: Voluntary?
    private var containter: NSPersistentContainer = AppDelegate.persistentContainer!
    private let fbDBRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailTeamSegue" {
            if let destination = segue.destination as? DetailTeamTableViewController, let team = sender as? Team {
                destination.team = team
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
        let  numberOfRows = voluntary?.teams?.count ?? 0
        return numberOfRows
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell", for: indexPath)
        if let cell = cell as? TeamTableViewCell, let teamItems = voluntary?.teams?.allObjects as? [Team_Item] {
            cell.setup(withTeamItem: teamItems[indexPath.row])
            return cell
        } else {
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TeamTableViewCell {
            if let team = cell.team {
                performSegue(withIdentifier: "detailTeamSegue", sender: team)
            }
        }
    }
}

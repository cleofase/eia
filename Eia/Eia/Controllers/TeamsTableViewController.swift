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
import FirebaseAuth

class TeamsTableViewController: UITableViewController {
    public var voluntary: Voluntary?
    private var teamItems = [Team_Item]()
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
        let context = containter.viewContext
        let voluntaryId = Auth.auth().currentUser?.uid ?? ""
        if let voluntary = Voluntary.find(matching: voluntaryId, in: context) {
            self.voluntary = voluntary
            if let teamItems = voluntary.teams?.allObjects as? [Team_Item] {
                self.teamItems = teamItems.sorted(by: {($0.name ?? "") < ($1.name ?? "")})
            }
            tableView.reloadData()
        }
        retrieveVoluntaryFromCloud(withVoluntaryId: voluntaryId, completionWithSuccess: {[weak self] (voluntary) in
            DispatchQueue.main.async {[weak self] in
                self?.voluntary = voluntary
                if let teamItems = voluntary.teams?.allObjects as? [Team_Item] {
                    self?.teamItems = teamItems.sorted(by: {($0.name ?? "") < ($1.name ?? "")})
                }
                self?.tableView.reloadData()
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
        return teamItems.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell", for: indexPath)
        if let cell = cell as? TeamTableViewCell {
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

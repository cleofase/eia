//
//  ScalesTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 11/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

class ScalesTableViewController: UITableViewController {
    public var voluntary: Voluntary?
    private var containter: NSPersistentContainer = AppDelegate.persistentContainer!
    private let fbDBRef = Database.database().reference()
    private var scaleItems = [Scale_Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailScaleSegue" {
            if let destination = segue.destination as? DetailScaleTableViewController, let scale = sender as? Scale {
                destination.scale = scale
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
            if let scaleItems = voluntary.scales?.allObjects as? [Scale_Item] {
                self.scaleItems = scaleItems.sorted(by: {($0.start ?? Date()) > ($1.start ?? Date())})
            }
            tableView.reloadData()
        }
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
        return scaleItems.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scaleCell", for: indexPath)
        if let cell = cell as? ScaleTableViewCell {
            let scaleId = scaleItems[indexPath.row].identifier ?? ""
            cell.setup(withScaleId: scaleId)
            return cell
        } else {
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ScaleTableViewCell {
            if let scale = cell.scale {
                performSegue(withIdentifier: "detailScaleSegue", sender: scale)
            }
        }
    }
}

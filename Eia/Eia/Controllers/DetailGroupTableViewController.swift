//
//  DetailGroupTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 23/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseAuth

class DetailGroupTableViewController: UITableViewController {
    public var group: Group?
    private let container = AppDelegate.persistentContainer!
    private var teams = [Team]()
    private var volunteers = [Voluntary]()
    private var volunteersDataSource: DetailGroupVolunteersDataSource!
    private var teamsDataSource: DetailGroupTeamsDataSource!
    
    // MARK: - Outlets
    @IBOutlet weak var manageButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var leaderNameLabel: UILabel!
    @IBOutlet weak var teamsTableView: UITableView!
    @IBOutlet weak var volunteersTableView: UITableView!
    
    // MARK: - Actions
    @IBAction func manageButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Criar Equipe", style: .default, handler: {[weak self](action) in
            self?.performSegue(withIdentifier: "newTeamSegue", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Editar", style: .default, handler: {[weak self](action) in
            self?.performSegue(withIdentifier: "editGroupSegue", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
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
        if segue.identifier == "editGroupSegue" {
            if let destination = segue.destination as? EditGroupTableViewController {
                destination.group = group
            }
        }
        if segue.identifier == "newTeamSegue" {
            if let destination = segue.destination as? NewTeamTableViewController {
                destination.group = group
            }
        }
    }
    private func setupUI() {
        let context = container.viewContext
        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
        photoImageView.clipsToBounds = true
        guard let group = group else {return}
        teamsTableView.tableFooterView = UIView()
        volunteersTableView.tableFooterView = UIView()
        volunteersDataSource = DetailGroupVolunteersDataSource(withGroup: group, context: context)
        volunteersTableView.dataSource = volunteersDataSource
        teamsDataSource = DetailGroupTeamsDataSource(withGroup: group, context: context)
        teamsTableView.dataSource = teamsDataSource
        manageButtonOutlet.isEnabled = false
        if let user = Auth.auth().currentUser {
            let identifier = user.uid
            if group.leader_id == identifier {
                manageButtonOutlet.isEnabled = true
            }
        }
    }
    private func updateUI() {
        guard let group = group else {return}
        nameLabel.text = group.name
        descriptionLabel.text = group.group_description
        leaderNameLabel.text = group.leader_name
        if let photoStr = group.photo_str, let photoData = Data(base64Encoded: photoStr), let photoImage = UIImage(data: photoData) {
            photoImageView.image = photoImage
        } else {
            // photo default...
        }
        teamsTableView.reloadData()
        volunteersTableView.reloadData()
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
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

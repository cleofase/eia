//
//  DetailTeamTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 02/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseAuth

class DetailTeamTableViewController: UITableViewController {
    public var team: Team?
    private let container = AppDelegate.persistentContainer!
    private var volunteersDataSource: DetailTeamVolunteersDataSource!
    private var scalesDataSource: DetailTeamScalesDataSource!
    
    @IBOutlet weak var manageButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var leaderNameLabel: UILabel!
    @IBOutlet weak var volunteersTableView: UITableView!
    @IBOutlet weak var scalesTableView: UITableView!
    
    @IBAction func manageButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Criar Escala", style: .default, handler: {[weak self](action) in
            self?.performSegue(withIdentifier: "newScaleSegue", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Editar", style: .default, handler: {[weak self](action) in
            self?.performSegue(withIdentifier: "editTeamSegue", sender: nil)
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
        if segue.identifier == "editTeamSegue" {
            if let destination = segue.destination as? EditTeamTableViewController {
                destination.team = team
            }
        }
        if segue.identifier == "newScaleSegue" {
            if let destination = segue.destination as? NewScaleTableViewController {
                destination.team = team
            }
        }
        if segue.identifier == "detailScaleFromTeamSegue" {
            if let destination = segue.destination as? DetailScaleTableViewController, let scale = sender as? Scale {
                destination.scale = scale
                destination.team = team
            }
        }
    }
    private func setupUI() {
        let context = container.viewContext
        guard let team = team else {return}
        tableView.tableFooterView = UIView()
        volunteersTableView.tableFooterView = UIView()
        volunteersDataSource = DetailTeamVolunteersDataSource(withTeam: team, context: context)
        volunteersTableView.dataSource = volunteersDataSource
        scalesTableView.tableFooterView = UIView()
        scalesDataSource = DetailTeamScalesDataSource(withTeam: team, in: context, at: self)
        scalesTableView.dataSource = scalesDataSource
        scalesTableView.delegate = scalesDataSource
        manageButtonOutlet.isEnabled = false
        if let user = Auth.auth().currentUser {
            let identifier = user.uid
            if team.leader_id == identifier {
                manageButtonOutlet.isEnabled = true
            }
        }
    }
    private func updateUI() {
        guard let team = team else {return}
        teamNameLabel.text = team.name
        groupNameLabel.text = team.group_name
        leaderNameLabel.text = team.leader_name
        scalesDataSource.refresh()
        volunteersTableView.reloadData()
        scalesTableView.reloadData()
    }
    private enum FormSectionContentType: Int {
        case teamName = 0
        case groupName = 1
        case leaderName = 2
        case volunteers = 3
        case scales = 4
        
        func heightForRow(with team: Team?) -> CGFloat {
            switch self {
            case .teamName:
                return 40
            case .groupName:
                return 40
            case .leaderName:
                return 40
            case .volunteers:
                if let numberOfVolunteers = team?.volunteers?.count {
                    return CGFloat(44 * numberOfVolunteers + 44)
                } else {
                    return 44
                }
            case .scales:
                if let numberOfScales = team?.scales?.count {
                    return CGFloat(60 * numberOfScales + 60)
                } else {
                    return 60
                }
            }
        }
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
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        if let contentType = FormSectionContentType(rawValue: section) {
            return contentType.heightForRow(with: team)
        } else {
            return 40
        }
    }
}

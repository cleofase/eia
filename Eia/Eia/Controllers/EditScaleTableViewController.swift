//
//  EditScaleTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 26/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

class EditScaleTableViewController: EiaFormTableViewController {
    // MARK: - Public vars
    public var scale: Scale?
    
    // MARK: - Private vars
    private var container: NSPersistentContainer = AppDelegate.persistentContainer!
    private let fbDBRef = Database.database().reference()
    private var invitationsDataSource: EditScaleInvitationsDataSource!
    
    // MARK: - Outlets
    @IBOutlet weak var teamNameTextField: TeamNameTextField!
    @IBOutlet weak var alertTeamNameLabel: UILabel!
    @IBOutlet weak var scaleStatusTextField: ScaleStatusTextField!
    @IBOutlet weak var alertScaleStatusLabel: UILabel!
    @IBOutlet weak var startScaleTextField: BeginScaleTextField!
    @IBOutlet weak var alertStartScaleLabel: UILabel!
    @IBOutlet weak var endScaleTextField: EndScaleTextField!
    @IBOutlet weak var alertEndScaleLabel: UILabel!
    @IBOutlet weak var invitationsTableView: UITableView!
    
    // MARK: - Actions
    @IBAction func confirmButton(_ sender: UIBarButtonItem) {
        performFormValidation(validationDidFinishWithSuccess: {[weak self] (formValid) in
            if formValid {
                let start = self?.startScaleTextField.date ?? Date()
                let end = self?.endScaleTextField.date ?? Date()
                self?.saveScaleWithExit(withStarting: start, end: end)
            } else {
                self?.becomeFirstNotValidFieldFirstResponder()
            }
        })
    }
    
    // MARK: - UIViewController
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
    
    // MARK: - UI Funcs
    private func setupUI() {
        let context = container.viewContext
        guard let scale = scale else {return}
        teamNameTextField.isEnabled = false
        scaleStatusTextField.isEnabled = false
        startScaleTextField.delegate = self
        endScaleTextField.delegate = self
        eiaTextFields = [startScaleTextField, endScaleTextField]
        alertLabels = [alertStartScaleLabel, alertEndScaleLabel]
        invitationsDataSource = EditScaleInvitationsDataSource(withScale: scale, context: context)
        invitationsTableView.dataSource = invitationsDataSource
        invitationsTableView.tableFooterView = UIView()
    }
    private func updateUI() {
        guard let scale = scale else {return}
        teamNameTextField.text = scale.team_name
        alertTeamNameLabel.text?.removeAll()
        scaleStatusTextField.text = scale.status
        alertScaleStatusLabel.text?.removeAll()
        startScaleTextField.date = scale.start
        alertStartScaleLabel.text?.removeAll()
        endScaleTextField.date = scale.end
        alertEndScaleLabel.text?.removeAll()
        invitationsTableView.reloadData()
    }
    
    // MARK: - Business Funcs
    private func saveScaleWithExit(withStarting start: Date, end: Date) {
        guard let scale = scale else {return}
        let context = container.viewContext
        scale.start = start
        scale.end = end
        try? context.save()
        
        let scaleId = scale.identifier ?? ""
        fbDBRef.child(Scale.rootFirebaseDatabaseReference).child(scaleId).setValue(scale.dictionaryValue)
        navigationController?.popViewController(animated: true)
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

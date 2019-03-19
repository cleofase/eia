//
//  DetailScaleTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 15/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

class DetailScaleTableViewController: UITableViewController {
    // MARK: - Public Vars
    public var scale: Scale?
    public var team: Team?
    
    // MARK: - Private Vars
    private let container = AppDelegate.persistentContainer!
    private var invitationsDataSource: DetailScaleInvitationsDataSource!
    private let fbDbRef = Database.database().reference()
    private var myInvitationStatus: InvitationStatus? {
        get {
            let context = container.viewContext
            let scaleId = scale?.identifier ?? ""
            if let scale = Scale.find(matching: scaleId, in: context) {
                guard let myId = Auth.auth().currentUser?.uid else {return nil}
                if let invitation = scale.findInvitationItem(withVoluntaryId: myId, in: context) {
                    return InvitationStatus(rawValue: invitation.status ?? "")
                }
            }
            return nil
        }
    }
    private lazy var iAmInvited: Bool = {
        guard let scale = scale else {return false}
        guard let myId = Auth.auth().currentUser?.uid else {return false}
        if let invitations = scale.invitations?.allObjects as? [Invitation_Item] {
            return invitations.contains(where: {$0.identifier == myId})
        }
        return false
    }()
    private lazy var iAmLeader: Bool = {
        guard let scale = scale else {return false}
        guard let myId = Auth.auth().currentUser?.uid else {return false}
        if let leaderId: String = scale.leader_id, leaderId.count > 0 {
            return leaderId == myId
        }
        return false
    }()
    private lazy var iBelongTeam: Bool = {
        guard let scale = scale else {return false}
        guard let team = team else {return false}
        guard let myId = Auth.auth().currentUser?.uid else {return false}
        if let volunteers = team.volunteers?.allObjects as? [Voluntary_Item] {
            return volunteers.contains(where: {$0.identifier == myId})
        }
        return false
    }()
    @IBOutlet weak var manageButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var scaleNavigationItem: UINavigationItem!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var startScaleLabel: UILabel!
    @IBOutlet weak var endScaleLabel: UILabel!
    @IBOutlet weak var invitationsTableView: UITableView!
    @IBAction func manageButton(_ sender: UIBarButtonItem) {
        guard let scaleStatus = ScaleStatus(rawValue: scale?.status ?? "") else {return}
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if iAmLeader {
            switch scaleStatus {
            case .created:
                alert.addAction(confirmScaleAction)
                alert.addAction(editScaleAction)
                alert.addAction(cancelScaleAction)
            case .confirmed:
                alert.addAction(finishScaleAction)
                alert.addAction(cancelScaleAction)
            case .canceled, .done:
                break
            }
        }
        if iBelongTeam {
            if let myInvitationStatus = myInvitationStatus {
                switch scaleStatus {
                case .created, .confirmed:
                    switch myInvitationStatus {
                    case .created:
                        alert.addAction(requestExchangeAction)
                        alert.addAction(acceptInvitationAction)
                    case .accepted:
                        alert.addAction(requestExchangeAction)
                        alert.addAction(rejectInvitationAction)
                    case .canceled, .refused:
                        break
                    }
                case .canceled, .done:
                    break
                }
            }
        }
        if iAmInvited {
            if let myInvitationStatus = myInvitationStatus {
                switch scaleStatus {
                case .created, .confirmed:
                    switch myInvitationStatus {
                    case .created:
                        alert.addAction(acceptInvitationAction)
                        alert.addAction(rejectInvitationAction)
                    case .accepted:
                        alert.addAction(rejectInvitationAction)
                    case .refused, .canceled:
                        break
                    }
                case .canceled, .done:
                    break
                }
            }
        }
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Manage Alert Actions
    private var confirmScaleAction: UIAlertAction {
        get {
            return UIAlertAction(title: "Confirmar Escala", style: .default, handler: {[weak self](action) in
                self?.confirmScale()
            })
        }
    }
    private var cancelScaleAction: UIAlertAction {
        get {
            return UIAlertAction(title: "Cancelar Escala", style: .destructive, handler: {[weak self](action) in
                self?.cancelScale()
            })
        }
    }
    private var editScaleAction: UIAlertAction {
        get {
            return UIAlertAction(title: "Editar Escala", style: .default, handler: {[weak self](action) in
                self?.editScale()
            })
        }
    }
    private var finishScaleAction: UIAlertAction {
        get {
            return UIAlertAction(title: "Concluir Escala", style: .default, handler: {[weak self](action) in
                self?.finishScale()
            })
        }
    }
    private var requestExchangeAction: UIAlertAction {
        get {
            return UIAlertAction(title: "Solicitar Troca", style: .default, handler: {[weak self](action) in
                self?.requestExchange()
            })
        }
    }
    private var acceptInvitationAction: UIAlertAction {
        get {
            return UIAlertAction(title: "Aceitar Convite", style: .default, handler: {[weak self](action) in
                self?.acceptInvitation()
            })
        }
    }
    private var rejectInvitationAction: UIAlertAction {
        get {
            return UIAlertAction(title: "Rejeitar Convite", style: .default, handler: {[weak self](action) in
                self?.rejectInvitation()
            })
        }
    }
    private var cancelAction: UIAlertAction {
        get {
            return UIAlertAction(title: "Voltar", style: .cancel, handler: nil)
        }
    }

    // MARK: - Manage Scale Functions
    private func confirmScale() {
        changeScaleStatus(toStatus: .confirmed)
        updateUI()
    }
    private func cancelScale() {
        changeScaleStatus(toStatus: .canceled)
        updateUI()
    }
    private func editScale() {
        performSegue(withIdentifier: "editScaleSegue", sender: self)
    }
    private func finishScale() {
        changeScaleStatus(toStatus: .done)
        updateUI()
    }
    private func requestExchange() {
        performSegue(withIdentifier: "requestExchangeSegue", sender: self)
    }
    private func acceptInvitation() {
        changeInvitationStatus(toStatus: InvitationStatus.accepted)
        updateUI()
    }
    private func rejectInvitation() {
        changeInvitationStatus(toStatus: InvitationStatus.refused)
        updateUI()
    }
    private func changeInvitationStatus(toStatus status: InvitationStatus) {
        guard let voluntaryId = Auth.auth().currentUser?.uid else {return}
        guard let scale = scale else {return}
        let context = container.viewContext
        let newStatus = status.stringValue
        
        if let invitationItem = scale.findInvitationItem(withVoluntaryId: voluntaryId, in: context) {
            let invitationId = invitationItem.identifier ?? ""
            let scaleId = scale.identifier ?? ""
            invitationItem.status = newStatus
            try? context.save()
            fbDbRef.child(Scale.rootFirebaseDatabaseReference).child(scaleId).child(Invitation_Item.rootFirebaseDatabaseReference).child(invitationId).setValue(invitationItem.dictionaryValue)
            if let invitation = Invitation.find(matching: invitationId, in: context) {
                invitation.status = newStatus
                try? context.save()
                fbDbRef.child(Invitation.rootFirebaseDatabaseReference).child(invitationId).setValue(invitation.dictionaryValue)
            }
            if let voluntary = Voluntary.find(matching: voluntaryId, in: context) {
                if let invitationItem = voluntary.findInvitationItem(withInvitationId: invitationId, in: context) {
                    invitationItem.status = newStatus
                    try? context.save()
                    fbDbRef.child(Voluntary.rootFirebaseDatabaseReference).child(voluntaryId).child(Invitation_Item.rootFirebaseDatabaseReference).child(invitationId).setValue(invitationItem.dictionaryValue)
                }
            }
        }
    }
    private func changeScaleStatus(toStatus status: ScaleStatus) {
        guard let scale = scale else {return}
        let context = container.viewContext
        scale.status = status.stringValue
        
        let teamId = scale.team_id ?? ""
        let scaleId = scale.identifier ?? ""
        if let team = Team.find(matching: teamId, in: context) {
            if let scaleItems = team.scales?.allObjects as? [Scale_Item] {
                if let scaleItem = scaleItems.first(where: {$0.identifier == scaleId}) {
                    scaleItem.status = status.stringValue
                }
            }
        }
        try? context.save()
        fbDbRef.child(Scale.rootFirebaseDatabaseReference).child(scaleId).setValue(scale.dictionaryValue)
        fbDbRef.child(Team.rootFirebaseDatabaseReference).child(teamId).setValue(team?.dictionaryValue)
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editScaleSegue" {
            if let destination = segue.destination as? EditScaleTableViewController {
                destination.scale = scale
            }
        }
        if segue.identifier == "requestExchangeSegue" {
            if let destination = segue.destination as? RequestExchangeTableViewController {
                destination.scale = scale
            }
        }
    }
    // MARK: - UI Functions
    private func setupUI() {
        let context = container.viewContext
        guard let scale = scale else {return}
        invitationsTableView.tableFooterView = UIView()
        invitationsDataSource = DetailScaleInvitationsDataSource(withScale: scale, context: context)
        invitationsTableView.dataSource = invitationsDataSource
        invitationsTableView.delegate = invitationsDataSource
        manageButtonOutlet.isEnabled = false
        if team == nil {
            let teamId = scale.team_id ?? ""
            updateTeamFromCloud(withTeamId: teamId)
        }
    }
    private func updateUI() {
        let context = container.viewContext
        let scaleId = scale?.identifier ?? ""
        scale = Scale.find(matching: scaleId, in: context)
        guard let scale = scale else {return}
        scaleNavigationItem.title = scale.status
        teamNameLabel.text = scale.team_name
        startScaleLabel.text = scale.start?.dateHourStringValue
        endScaleLabel.text = scale.end?.dateHourStringValue
        handleManageButtonVisibility()
        invitationsDataSource.refresh()
        invitationsTableView.reloadData()
    }
    private func handleManageButtonVisibility() {
        if let scaleStatus = ScaleStatus(rawValue: scale?.status ?? "") {
            switch scaleStatus {
            case .created, .confirmed:
                manageButtonOutlet.isEnabled = iAmLeader || iBelongTeam || iAmInvited
            default:
                manageButtonOutlet.isEnabled = false
            }
        } else {
            manageButtonOutlet.isEnabled = false
        }
    }
    private func updateTeamFromCloud(withTeamId teamId: String) {
        let context = container.viewContext
        fbDbRef.child(Team.rootFirebaseDatabaseReference).child(teamId).observeSingleEvent(of: .value, with: {[weak self](snapshot) in
            if let teamDic = snapshot.value as? NSDictionary {
                DispatchQueue.main.async {[weak self] in
                    if let team = Team.createOrUpdate(matchDictionary: teamDic, in: context) {
                        self?.team = team
                        try? context.save()
                        self?.updateUI()
                    }
                }
            }
        })
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
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

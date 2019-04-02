//
//  ResetPasswordTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 23/12/18.
//  Copyright © 2018 Cleofas Pereira. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class ResetPasswordTableViewController: EiaFormTableViewController {
    private let workingIndicator = WorkingIndicator()
    
    @IBOutlet weak var emailTextField: EmailTextField!
    @IBOutlet weak var alertEmailLabel: UILabel!
    @IBOutlet weak var coverResetPasswordView: UIView!
    @IBOutlet weak var coverLoginView: UIView!
    
    @IBAction func resetPasswordButton(_ sender: MainFlowButton) {
        hideFormButtons()
        workingIndicator.show(at: coverLoginView)
        performFormValidation(validationDidFinishWithSuccess: {[weak self] (formValid) in
            if formValid {
                let email = self?.emailTextField.text ?? ""
                self?.perfomResetPassword(withEmail: email) {[weak self] (success) in
                    self?.workingIndicator.hide()
                    self?.showFormButtons()
                    if success {
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                self?.workingIndicator.hide()
                self?.showFormButtons()
                self?.becomeFirstNotValidFieldFirstResponder()
            }
        })
    }
    @IBAction func loginButton(_ sender: AlternativeFlowButton) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerFieldsToDinamicValidation()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deRegisterFieldsToDinamicValidation()
    }
    private func setupUI() {
        tableView.tableFooterView = UIView()
        emailTextField.delegate = self
        eiaTextFields = [emailTextField]
        alertLabels = [alertEmailLabel]
        showFormButtons()
    }
    private func hideFormButtons() {
        coverLoginView.isHidden = false
        coverResetPasswordView.isHidden = false
    }
    private func showFormButtons() {
        coverLoginView.isHidden = true
        coverResetPasswordView.isHidden = true
    }
    private func perfomResetPassword(withEmail email: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) {(error) in
            if let error = error {
                let serverError = EiaError(withType: EiaErrorType.serverError)
                serverError.showAsAlert(title: "Reiniciar Senha", controller: self, complement: error.localizedDescription) {
                    completion(false)
                }
            } else {
                // send instructions alert
                completion(true)
            }
        }
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.endEditing(true)
    }
    private enum RowType: Int {
        case Logo = 0
        case Description = 1
        case EmailField = 2
        case ResetButton = 3
        case LoginButton = 4
        
        init?(withRow row: Int) {
            if let rowType = RowType(rawValue: row) {
                self = rowType
            } else {
                return nil
            }
        }
        var height: CGFloat {
            get {
                switch self {
                case .Logo:
                    return 112
                case .Description:
                    return 88
                case .EmailField:
                    return 64
                case .ResetButton:
                    return 64
                case .LoginButton:
                    return 64
                }
            }
        }
        static var sunOfFixedRows: CGFloat {
            get {
                var sun: CGFloat = 0
                let rowType = RowType.EmailField
                switch rowType {
                case .EmailField:
                    sun += RowType.EmailField.height; fallthrough
                case .ResetButton:
                    sun += RowType.ResetButton.height; fallthrough
                case .LoginButton:
                    sun += RowType.LoginButton.height
                default:
                    sun += 0
                }
                return sun
            }
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let rowType = RowType(withRow: indexPath.row) {
            switch rowType {
            case .Logo, .Description:
                return max((view.bounds.height - view.safeAreaInsets.top - RowType.sunOfFixedRows)/2, rowType.height)
            default:
                return rowType.height
            }
        } else {
            return 0
        }
    }
    
}

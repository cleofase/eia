//
//  LoginTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 23/12/18.
//  Copyright © 2018 Cleofas Pereira. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class LoginTableViewController: EiaFormTableViewController {
    
    @IBOutlet weak var emailTextField: EmailTextField!
    @IBOutlet weak var alertEmailLabel: UILabel!
    @IBOutlet weak var passwordTextField: PasswordTextField!
    @IBOutlet weak var alertPasswordLabel: UILabel!
    
    @IBAction func loginButton(_ sender: MainFlowButton) {
        performFormValidation(validationDidFinishWithSuccess: {[weak self] (formValid) in
            if formValid {
                let email = self?.emailTextField.text ?? ""
                let password = self?.passwordTextField.text ?? ""
                self?.performLogin(withEmail: email, password: password) {[weak self] (success) in
                    if success {
                        self?.goToHomeScreen()
                    }
                }
            } else {
                self?.becomeFirstNotValidFieldFirstResponder()
            }
        })
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
        passwordTextField.delegate = self
        eiaTextFields = [emailTextField, passwordTextField]
        alertLabels = [alertEmailLabel, alertPasswordLabel]
    }
    private func performLogin(withEmail email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) {(authResult, error) in
            if let error = error {
                let serverError = EiaError(withType: .serverError)
                serverError.showAsAlert(title: "Login", controller: self, complement: error.localizedDescription) {
                    completion(false)
                }
            } else {
                if let authResult = authResult {
                    if authResult.user.isEmailVerified {
                        completion(true)
                    } else {
                        let serverError = EiaError(withType: .emailVerificationPending)
                        serverError.showAsAlert(title: "Login", controller: self, complement: nil) {
                            completion(false)
                        }
                    }
                } else {
                    let serverError = EiaError(withType: .serverError)
                    serverError.showAsAlert(title: "Login", controller: self, complement: nil) {
                        completion(false)
                    }
                }
            }
        }
    }
    private func goToHomeScreen() {
        DispatchQueue.main.async {[weak self] in
            self?.performSegue(withIdentifier: "homeScreenSegue", sender: self)
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.endEditing(true)
    }
    private enum RowType: Int {
        case Logo = 0
        case Title = 1
        case EmailField = 2
        case PasswordField = 3
        case LoginButton = 4
        case ForgetButton = 5
        case SignUpButton = 6
        
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
                    return 88
                case .Title:
                    return 88
                case .EmailField:
                    return 64
                case .PasswordField:
                    return 64
                case .LoginButton:
                    return 64
                case .ForgetButton:
                    return 64
                case .SignUpButton:
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
                case .PasswordField:
                    sun += RowType.PasswordField.height; fallthrough
                case .LoginButton:
                    sun += RowType.LoginButton.height; fallthrough
                case .ForgetButton:
                    sun += RowType.ForgetButton.height; fallthrough
                case .SignUpButton:
                    sun += RowType.SignUpButton.height
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
            case .Logo, .Title:
                return max((view.bounds.height - view.safeAreaInsets.top - RowType.sunOfFixedRows)/2, rowType.height)
            default:
                return rowType.height
            }
        } else {
            return 0
        }
    }

}

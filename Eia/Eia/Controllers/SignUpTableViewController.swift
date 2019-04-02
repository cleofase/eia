//
//  SignUpTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 23/12/18.
//  Copyright © 2018 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

class SignUpTableViewController: EiaFormTableViewController {
    private var containter: NSPersistentContainer = AppDelegate.persistentContainer!
    private let fbDbRef = Database.database().reference()
    private let workingIndicator = WorkingIndicator()

    @IBOutlet weak var nameTextField: UserTextField!
    @IBOutlet weak var alertNameLabel: UILabel!
    @IBOutlet weak var emailTextField: EmailTextField!
    @IBOutlet weak var alertEmailLabel: UILabel!
    @IBOutlet weak var passwordTextField: PasswordTextField!
    @IBOutlet weak var alertPasswordLabel: UILabel!
    @IBOutlet weak var rePasswordTextField: RePasswordTextField!
    @IBOutlet weak var alertRePasswordLabel: UILabel!
    @IBOutlet weak var coverSignUpView: UIView!
    @IBOutlet weak var coverLoginView: UIView!
    
    
    @IBAction func signUpButton(_ sender: MainFlowButton) {
        hideFormButtons()
        workingIndicator.show(at: coverLoginView)
        performFormValidation(validationDidFinishWithSuccess: {[weak self] (formValid) in
            if formValid {
                let name = self?.nameTextField.text ?? ""
                let email = self?.emailTextField.text ?? ""
                let password = self?.passwordTextField.text ?? ""
                self?.perfomSignUp(name: name, email: email, password: password) {[weak self] (success) in
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
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        rePasswordTextField.delegate = self
        rePasswordTextField.associatedPasswordTextField = passwordTextField
        eiaTextFields = [nameTextField, emailTextField, passwordTextField, rePasswordTextField]
        alertLabels = [alertNameLabel, alertEmailLabel, alertPasswordLabel, alertRePasswordLabel]
        showFormButtons()
    }
    private func hideFormButtons() {
        coverLoginView.isHidden = false
        coverSignUpView.isHidden = false
    }
    private func showFormButtons() {
        coverLoginView.isHidden = true
        coverSignUpView.isHidden = true
    }
    private func perfomSignUp(name: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        let context: NSManagedObjectContext = containter.viewContext
        Auth.auth().createUser(withEmail: email, password: password) {[weak self] (authResult, error) in
            if let error = error {
                let serverError = EiaError(withType: EiaErrorType.serverError)
                serverError.showAsAlert(title: "Cadastro", controller: self, complement: error.localizedDescription) {
                    completion(false)
                }
            } else {
                if let currentUser = authResult?.user {
                    self?.sendEmailVerification(email: email, password: password) {(success) in
                        if success {
                            let voluntary = Voluntary.create(with: currentUser, name: name, in: context)
                            try? context.save()
                            self?.persisteOnCloud(withVoluntary: voluntary) {
                                completion(true)
                            }
                        } else {
                            completion(false)
                        }
                    }
                } else {
                    let serverError = EiaError(withType: EiaErrorType.serverError)
                    serverError.showAsAlert(title: "Cadastro", controller: self, complement: nil) {
                        completion(false)
                    }
                }
            }
        }
        
        
    }
    private func sendEmailVerification(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) {[weak self] (user, error) in
            if let error = error {
                let serverError = EiaError(withType: EiaErrorType.serverError)
                serverError.showAsAlert(title: "Verificação de Email", controller: self, complement: error.localizedDescription) {
                    completion(false)
                }
            } else {
                Auth.auth().currentUser?.sendEmailVerification() {[weak self] (error) in
                    if let error = error {
                        let serverError = EiaError(withType: EiaErrorType.serverError)
                        serverError.showAsAlert(title: "Verificação de Email", controller: self, complement: error.localizedDescription) {
                            try? Auth.auth().signOut()
                            completion(false)
                        }
                    } else {
                        let feedback = EiaFeedback(withType: EiaFeedbackType.verificationEmailSent)
                        feedback.showAsAlert(at: self) {
                            try? Auth.auth().signOut()
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    private func persisteOnCloud(withVoluntary voluntary: Voluntary, completion: @escaping () -> Void) {
        let child = Voluntary.rootFirebaseDatabaseReference
        let authId = voluntary.authId ?? ""
        print(fbDbRef.debugDescription)
        print(voluntary.dictionaryValue.debugDescription)
        fbDbRef.child(child).child(authId).setValue(voluntary.dictionaryValue)
        completion()
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.endEditing(true)
    }
    private enum RowType: Int {
        case Logo = 0
        case Description = 1
        case UserName = 2
        case EmailField = 3
        case PasswordField = 4
        case RePasswordField = 5
        case SignUpButton = 6
        case LoginButton = 7
        
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
                case .UserName:
                    return 64
                case .EmailField:
                    return 64
                case .PasswordField:
                    return 64
                case .RePasswordField:
                    return 64
                case .SignUpButton:
                    return 64
                case .LoginButton:
                    return 64
                }
            }
        }
        static var sunOfFixedRows: CGFloat {
            get {
                var sun: CGFloat = 0
                let rowType = RowType.UserName
                switch rowType {
                case .UserName:
                    sun += RowType.UserName.height; fallthrough
                case .EmailField:
                    sun += RowType.EmailField.height; fallthrough
                case .PasswordField:
                    sun += RowType.PasswordField.height; fallthrough
                case .RePasswordField:
                    sun += RowType.RePasswordField.height; fallthrough
                case .SignUpButton:
                    sun += RowType.SignUpButton.height; fallthrough
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

//
//  SignUpTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 23/12/18.
//  Copyright © 2018 Cleofas Pereira. All rights reserved.
//

import UIKit

class SignUpTableViewController: UITableViewController {
    
    
    @IBAction func loginButton(_ sender: AlternativeFlowButton) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
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
                    return 88
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

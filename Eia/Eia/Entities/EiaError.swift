//
//  EiaError.swift
//  Eia
//
//  Created by Cleofas Pereira on 27/12/18.
//  Copyright © 2018 Cleofas Pereira. All rights reserved.
//

import Foundation
import UIKit

enum EiaErrorType: String {
    case groupNameEmpty = "GROUP_NAME_EMPTY"
    case groupNameTooShort = "GROUP_NAME_TOO_SHORT"
    case groupNameTooLong = "GROUP_NAME_TOO_LONG"
    case groupDescriptionEmpty = "GROUP_DESCRIPTION_EMPTY"
    case groupDescriptionTooShort = "GROUP_DESCRIPTION_TOO_SHORT"
    case groupDescriptionTooLong = "GROUP_DESCRIPTION_TOO_LONG"
    case nameEmpty = "NAME_EMPTY"
    case nameNotValid = "NAME_NOT_VALID"
    case nameTooShort = "NAME_TOO_SHORT"
    case nameTooLong = "NAME_TOO_LONG"
    case emailEmpty = "EMAIL_EMPTY"
    case emailNotValid = "EMAIL_NOT_VALID"
    case emailVerificationPending = "EMAIL_VERIFICATION_PENDING"
    case phoneNotValid = "PHONE_NOT_VALID"
    case passwordEmpty = "PASSWORD_EMPTY"
    case passwordNotValid = "PASSWORD_NOT_VALID"
    case rePasswordNotValid = "RE_PASSWORD_NOT_VALID"
    case errorNotMapped = "ERROR_NOT_MAPPED"
    case serverError = "SERVER_ERROR"
    case teamNameEmpty = "TEAM_NAME_EMPTY"
    case teamNameTooShort = "TEAM_NAME_TOO_SHORT"
    case teamNameTooLong = "TEAM_NAME_TOO_LONG"
    case scaleStatusEmpty = "SCALE_STATUS_EMPTY"
    case scaleStatusNotValid = "SCALE_STATUS_NOT_VALID"
    case substituteNotSelected = "SUBSTITUTE_NOT_SELECTED"
    case dateEmpty = "DATE_EMPTY"
    case endDateMinor = "END_DATE_MINOR"
    case dateNotValid = "DATE_NOT_VALID"
    
    var mnemonic: String {get{
        return self.rawValue
        }}
}

struct EiaError: Error {
    let type: EiaErrorType
    let description: String
    init(withType errorType: EiaErrorType ) {
        type = errorType
        description = NSLocalizedString(errorType.mnemonic, comment: "")
    }
    public func showAsAlert(title: String, controller: UIViewController?, complement: String?, completion: @escaping () -> Void) {
        let message = self.description + (complement ?? "")
        let alertError = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertError.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(_) in
            completion()
        }))
        controller?.present(alertError, animated: true, completion: nil)
    }
}

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

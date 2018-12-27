//
//  EiaError.swift
//  Eia
//
//  Created by Cleofas Pereira on 27/12/18.
//  Copyright © 2018 Cleofas Pereira. All rights reserved.
//

import Foundation

enum EiaErrorType: String {
    case nameEmpty = "NAME_EMPTY"
    case nameNotValid = "NAME_NOT_VALID"
    case emailEmpty = "EMAIL_EMPTY"
    case emailNotValid = "EMAIL_NOT_VALID"
    case phoneNotValid = "PHONE_NOT_VALID"
    case passwordEmpty = "PASSWORD_EMPTY"
    case passwordNotValid = "PASSWORD_NOT_VALID"
    case rePasswordNotValid = "RE_PASSWORD_NOT_VALID"
    case errorNotMapped = "ERROR_NOT_MAPPED"
    
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
}

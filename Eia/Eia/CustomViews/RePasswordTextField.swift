//
//  RePasswordFieldText.swift
//  Eia
//
//  Created by Cleofas Pereira on 27/12/18.
//  Copyright © 2018 Cleofas Pereira. All rights reserved.
//

import UIKit

class RePasswordTextField: PasswordTextField {
    weak public var associatedPasswordTextField: PasswordTextField?
    override func performeValidation() throws {
        do {
            try super.performeValidation()
            if let associatedPasswordTextField = associatedPasswordTextField {
                if text != associatedPasswordTextField.text {
                    markAsNotValid()
                    throw EiaError(withType: EiaErrorType.rePasswordNotValid)
                }
            }
        } catch {
            if let error = error as? EiaError {
                throw error
            }
        }
        markAsValid()
    }
}

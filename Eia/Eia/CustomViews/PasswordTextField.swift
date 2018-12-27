//
//  PasswordTextField.swift
//  Eia
//
//  Created by Cleofas Pereira on 23/12/18.
//  Copyright © 2018 Cleofas Pereira. All rights reserved.
//

import UIKit

class PasswordTextField: EiaTextField, ValidableField {
    let iconImage = UIImage(named: "password_field_icon")
    override init(frame: CGRect) {
        super.init(frame: frame)
        setIcon(with: iconImage)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setIcon(with: iconImage)
    }
    func performeValidation() throws {
        guard let text = text, text.count > 0 else {
            markAsNotValid()
            throw EiaError(withType: EiaErrorType.passwordEmpty)
        }
        if text.count < 8 {
            markAsNotValid()
            throw EiaError(withType: EiaErrorType.passwordNotValid)
        }
        markAsValid()
    }
}

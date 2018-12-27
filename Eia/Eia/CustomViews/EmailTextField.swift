//
//  EmailTextField.swift
//  Eia
//
//  Created by Cleofas Pereira on 23/12/18.
//  Copyright © 2018 Cleofas Pereira. All rights reserved.
//

import UIKit

class EmailTextField: EiaTextField, ValidableField {
    let iconImage = UIImage(named: "email_field_icon")
    override init(frame: CGRect) {
        super.init(frame: frame)
        setIcon(with: iconImage)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setIcon(with: iconImage)
    }
    func performeValidation() throws {
        let emailRegEx: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        guard let text = text, text.count > 0 else {
            markAsNotValid()
            throw EiaError(withType: EiaErrorType.emailEmpty)
        }
        if !NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: text) {
            markAsNotValid()
            throw EiaError(withType: EiaErrorType.emailNotValid)
        }
        markAsValid()
    }
}

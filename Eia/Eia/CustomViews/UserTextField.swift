//
//  UserTextField.swift
//  Eia
//
//  Created by Cleofas Pereira on 23/12/18.
//  Copyright © 2018 Cleofas Pereira. All rights reserved.
//

import UIKit

class UserTextField: EiaTextField, ValidableField {
    let iconImage = UIImage(named: "user_field_icon")
    override init(frame: CGRect) {
        super.init(frame: frame)
        setIcon(with: iconImage)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setIcon(with: iconImage)
    }
    func performeValidation() throws {
        let nameRegEx: String = "[A-Z0-9a-z._%+-]+"
        guard let text = text, text.count > 0 else {
            markAsNotValid()
            throw EiaError(withType: EiaErrorType.nameEmpty)
        }
        if !NSPredicate(format: "SELF MATCHES %@", nameRegEx).evaluate(with: text) {
            markAsNotValid()
            throw EiaError(withType: EiaErrorType.nameNotValid)
        }
        markAsValid()
    }
}

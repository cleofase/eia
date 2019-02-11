//
//  TeamNameTextField.swift
//  Eia
//
//  Created by Cleofas Pereira on 27/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit

class TeamNameTextField: EiaTextField, ValidableField {
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
        guard let text = text, text.count > 0 else {
            markAsNotValid()
            throw EiaError(withType: EiaErrorType.teamNameEmpty)
        }
        if text.count < 2 {
            markAsNotValid()
            throw EiaError(withType: EiaErrorType.teamNameTooShort)
        }
        if text.count > 16 {
            markAsNotValid()
            throw EiaError(withType: EiaErrorType.teamNameTooLong)
        }
        markAsValid()
    }
}

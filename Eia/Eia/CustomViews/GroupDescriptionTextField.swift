//
//  GroupDescriptionTextField.swift
//  Eia
//
//  Created by Cleofas Pereira on 10/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit

class GroupDescriptionTextField: EiaTextField, ValidableField {
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
            throw EiaError(withType: EiaErrorType.groupDescriptionEmpty)
        }
        if text.count < 2 {
            markAsNotValid()
            throw EiaError(withType: EiaErrorType.groupDescriptionTooShort)
        }
        if text.count > 64 {
            markAsNotValid()
            throw EiaError(withType: EiaErrorType.groupDescriptionTooLong)
        }
        markAsValid()
    }
}

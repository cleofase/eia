//
//  ScaleStatusTextField.swift
//  Eia
//
//  Created by Cleofas Pereira on 26/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit

class ScaleStatusTextField: EiaTextField, ValidableField {
    let iconImage = UIImage(named: "schedule_unselected_tab_icon")
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
        if let _ = ScaleStatus(rawValue: text) {
            markAsValid()
        } else {
            markAsNotValid()
            throw EiaError(withType: EiaErrorType.scaleStatusNotValid)
        }
    }

}

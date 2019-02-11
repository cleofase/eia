//
//  EndScaleTextField.swift
//  Eia
//
//  Created by Cleofas Pereira on 07/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit

class EndScaleTextField: BeginScaleTextField {
    weak public var initialDateTextField: BeginScaleTextField?

    override func performeValidation() throws {
        do {
            try super.performeValidation()
            if let initialDateTextField = initialDateTextField {
                if let beginDate = initialDateTextField.date, let endDate = self.date {
                    if beginDate.compare(endDate) == .orderedDescending {
                        markAsNotValid()
                        throw EiaError(withType: EiaErrorType.endDateMinor)
                    }
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


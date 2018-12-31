//
//  EiaFeedback.swift
//  Eia
//
//  Created by Cleofas Pereira on 29/12/18.
//  Copyright © 2018 Cleofas Pereira. All rights reserved.
//

import Foundation
import UIKit

enum EiaFeedbackType: String {
    case verificationEmailSent = "VERIIFCATION_EMAIL_SENT"
    
    var mnemonic: String {
        get {
        return self.rawValue
        }
    }
    var action: String {
        get {
            switch self {
            case .verificationEmailSent:
                return "E-Mail enviado!"
            }
        }
    }
}

struct EiaFeedback {
    let type: EiaFeedbackType
    let action: String
    let description: String
    init(withType feedbackType: EiaFeedbackType ) {
        type = feedbackType
        action = feedbackType.action
        description = NSLocalizedString(feedbackType.mnemonic, comment: "")
    }
    public func showAsAlert(at controller: UIViewController?, completion: @escaping () -> Void) {
        let alertFeedback = UIAlertController(title: self.action, message: self.description, preferredStyle: .alert)
        alertFeedback.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action) in
            completion()
        }))
        controller?.present(alertFeedback, animated: true, completion: nil)
    }
}

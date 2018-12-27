//
//  PhoneTextField.swift
//  Eia
//
//  Created by Cleofas Pereira on 26/12/18.
//  Copyright © 2018 Cleofas Pereira. All rights reserved.
//

import UIKit

class PhoneTextField: EiaTextField {
    let iconImage = UIImage(named: "phone_field_icon")
    override init(frame: CGRect) {
        super.init(frame: frame)
        setIcon(with: iconImage)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setIcon(with: iconImage)
    }
}

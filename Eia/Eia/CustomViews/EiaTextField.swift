//
//  EiaTextField.swift
//  Eia
//
//  Created by Cleofas Pereira on 23/12/18.
//  Copyright © 2018 Cleofas Pereira. All rights reserved.
//

import UIKit

class EiaTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public func setIcon(with image: UIImage?) {
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let iconView = UIImageView(frame: CGRect(x: 8, y: 8, width: 25, height: 25))
        iconView.image = image
        iconView.tintColor = UIColor(named: "Sand")
        leftView.addSubview(iconView)
        self.leftView = leftView
        leftViewMode = .always
    }
}

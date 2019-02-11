//
//  BeginScaleTextField.swift
//  Eia
//
//  Created by Cleofas Pereira on 07/02/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit

class BeginScaleTextField: EiaTextField, ValidableField {
    public var date: Date? {
        didSet {
            if let date = date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
                self.text = dateFormatter.string(from: date)
            }
        }
    }
    private let iconImage = UIImage(named: "schedule_unselected_tab_icon")
    private let toolbar = UIToolbar()
    let datePicker = UIDatePicker()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        setIcon(with: iconImage)
        datePicker.datePickerMode = .dateAndTime
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Ok", style: .plain, target: self, action: #selector(doneBottonAction))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(cancelButtonAction))
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        
        self.inputAccessoryView = toolbar
        self.inputView = datePicker
    }
    @objc private func doneBottonAction() {
        self.date = datePicker.date
        self.endEditing(true)
    }
    @objc private func cancelButtonAction() {
        self.endEditing(true)
    }
    func performeValidation() throws {
        guard let text = text, text.count > 0 else {
            markAsNotValid()
            throw EiaError(withType: EiaErrorType.dateEmpty)
        }
        if date == nil {
            markAsNotValid()
            throw EiaError(withType: EiaErrorType.dateNotValid)
        }
        markAsValid()
    }
}

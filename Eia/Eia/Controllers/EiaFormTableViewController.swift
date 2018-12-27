//
//  EiaFormTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 27/12/18.
//  Copyright © 2018 Cleofas Pereira. All rights reserved.
//

import UIKit

class EiaFormTableViewController: UITableViewController {
    public var eiaTextFields = [EiaTextField]()
    public var alertLabels = [UILabel]()
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    private func performEditedTextFieldsValidation() {
        for (index, eiaTextField) in eiaTextFields.enumerated() {
            if let validableTextField = eiaTextField as? ValidableField, eiaTextField.wasEdited {
                do {
                    try validableTextField.performeValidation()
                    alertLabels[index].text?.removeAll()
                    eiaTextField.markAsValid()
                } catch {
                    if let error = error as? EiaError {
                        alertLabels[index].text = error.description
                        eiaTextField.markAsNotValid()
                    } else {
                        let errorNotMapped = EiaError(withType: EiaErrorType.errorNotMapped)
                        alertLabels[index].text = errorNotMapped.description
                        eiaTextField.markAsNotValid()
                    }
                }
            }
        }
    }
    public func registerFieldsToDinamicValidation() {
        for eiaTextField in eiaTextFields {
            if let _ = eiaTextField as? ValidableField {
                eiaTextField.addTarget(self, action: #selector(performDinamicValidation), for: .editingChanged)
            }
        }
    }
    public func deRegisterFieldsToDinamicValidation() {
        for eiaTextField in eiaTextFields {
            if let _ = eiaTextField as? ValidableField {
                eiaTextField.removeTarget(self, action: nil, for: .editingChanged)
            }
        }
    }
    @objc func performDinamicValidation() {
        if let timer = timer {
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: {[weak self] (timer) in
            self?.performEditedTextFieldsValidation()
        })
    }
    public func performFormValidation(validationDidFinishWithSuccess: @escaping (Bool) -> Void) {
        var finishWithSuccess: Bool = true
        for (index, eiaTextField) in eiaTextFields.enumerated() {
            if let validableTextField = eiaTextField as? ValidableField {
                do {
                    try validableTextField.performeValidation()
                    alertLabels[index].text?.removeAll()
                    eiaTextField.markAsValid()
                } catch {
                    finishWithSuccess = false
                    if let error = error as? EiaError {
                        alertLabels[index].text = error.description
                        eiaTextField.markAsNotValid()
                    } else {
                        let errorNotMapped = EiaError(withType: EiaErrorType.errorNotMapped)
                        alertLabels[index].text = errorNotMapped.description
                        eiaTextField.markAsNotValid()
                    }
                }
            }
        }
        validationDidFinishWithSuccess(finishWithSuccess)
    }
    public func becomeFirstNotValidFieldFirstResponder() {
        for eiaTextField in eiaTextFields {
            if !eiaTextField.markedAsValid {
                eiaTextField.becomeFirstResponder()
                return
            }
        }
    }
}

extension EiaFormTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let eiaTextField = textField as? EiaTextField {
            if let index = eiaTextFields.firstIndex(of: eiaTextField) {
                if index < eiaTextFields.count - 1 {
                    eiaTextFields[index + 1].becomeFirstResponder()
                } else {
                    eiaTextField.endEditing(true)
                }
            }
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let eiaTextField = textField as? EiaTextField {
            eiaTextField.wasEdited = true
        }
        return true
    }
}

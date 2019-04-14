//
//  EiaDate.swift
//  Eia
//
//  Created by Cleofas Pereira on 13/04/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import Foundation

extension Date {
    var hourStringValue: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            return dateFormatter.string(from: self)
        }
    }
    var dateStringValue: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .short
            return dateFormatter.string(from: self)
        }
    }
    var dateHourStringValue: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            return dateFormatter.string(from: self)
        }
    }
}

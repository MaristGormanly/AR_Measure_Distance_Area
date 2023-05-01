//
//  UserDefaultsExtensions.swift
//  AR Measure
//
//  Created by banu, pitta on 30/04/23.
//

import Foundation


extension UserDefaults {
    
    var measureType: MeasureType {
        get {
            MeasureType(rawValue: string(forKey: "measureType") ?? "") ?? .centimeters
        }
        set {
            set(newValue.rawValue, forKey: "measureType")
        }
    }
}

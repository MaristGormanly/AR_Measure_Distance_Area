//
//  SettingsVC.swift
//  AR Measure
//
//  Created by banu, pitta on 30/04/23.
//

import Foundation
import UIKit


class SettingsVC: UIViewController {
    
    @IBOutlet weak var centimetersSwitch: UISwitch!
    @IBOutlet weak var metersSwitch: UISwitch!
    @IBOutlet weak var inchesSwitch: UISwitch!
    
    
    // MARK: - view life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        if UserDefaults.standard.measureType == .centimeters {
            setSwitchStateWith(sender: centimetersSwitch)
        } else if UserDefaults.standard.measureType == .meters {
            setSwitchStateWith(sender: metersSwitch)
        } else if UserDefaults.standard.measureType == .inches {
            setSwitchStateWith(sender: inchesSwitch)
        }
    }
    
    // MARK: - user actions
    
    @IBAction func measurementChanged(_ sender: UISwitch) {
        setSwitchStateWith(sender: sender)
    }
    
    // MARK: - Helper functions
    
    func setSwitchStateWith(sender: UISwitch) {
        if sender.tag == 1 {
            centimetersSwitch.isOn = sender.isOn
            if sender.isOn == false {
                metersSwitch.isOn = true
                UserDefaults.standard.measureType = .meters
            } else {
                metersSwitch.isOn = false
                UserDefaults.standard.measureType = .centimeters
            }
            inchesSwitch.isOn = false
        } else if sender.tag == 2 {
            metersSwitch.isOn = sender.isOn
            if sender.isOn == false {
                inchesSwitch.isOn = true
                UserDefaults.standard.measureType = .inches
            } else {
                inchesSwitch.isOn = false
                UserDefaults.standard.measureType = .meters
            }
            centimetersSwitch.isOn = false
        } else if sender.tag == 3 {
            inchesSwitch.isOn = sender.isOn
            if sender.isOn == false {
                centimetersSwitch.isOn = true
                UserDefaults.standard.measureType = .centimeters
            } else {
                centimetersSwitch.isOn = false
                UserDefaults.standard.measureType = .inches
            }
            metersSwitch.isOn = false
        }
    }
}

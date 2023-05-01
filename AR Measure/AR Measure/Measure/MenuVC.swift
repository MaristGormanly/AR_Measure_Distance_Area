//
//  MenuVC.swift
//  AR Measure
//
//  Created by banu, pitta on 23/04/23.
//

import Foundation
import UIKit

class MenuVC: UIViewController {
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - user actions
    
    @IBAction func loadMeasureAreaVC(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let areaMeasureVC = storyBoard.instantiateViewController(withIdentifier: "AreaMeasureVC") as! AreaMeasureVC
        self.navigationController?.pushViewController(areaMeasureVC, animated: true)
    }
    
    @IBAction func loadDistanceCaliculatorVC(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let distanceMeasureVC = storyBoard.instantiateViewController(withIdentifier: "DistanceMeasureVC") as! DistanceMeasureVC
        self.navigationController?.pushViewController(distanceMeasureVC, animated: true)
    }
    
    
    @IBAction func loadSettingsVC(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let settingsVC = storyBoard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @IBAction func exitApplication(_ sender: UIButton) {
        fatalError("Exiting application")
    }
}

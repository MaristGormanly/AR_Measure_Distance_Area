//
//  BaseMeasureSCNView.swift
//  AR Measure
//
//  Created by banu, pitta on 23/04/23.
//

import Foundation
import UIKit
import ARKit

open class BaseMeasureSCNView: ARSCNView {
    
    private var configuration = ARWorldTrackingConfiguration()
    var markedPoints = [SCNVector3]()
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    //MARK: - Helper functions
    
    private func setUp() {
        let scene = SCNScene()
        
        self.automaticallyUpdatesLighting = true
        self.scene = scene
        configuration.planeDetection = [.horizontal]
    }
    
    func hitResult(forPoint point: CGPoint) -> SCNVector3? {
        let hitTestResults = hitTest(point, types: .featurePoint)
        if let result = hitTestResults.first {
            let vector = result.worldTransform.columns.3
            return SCNVector3(vector.x, vector.y, vector.z)
        } else {
            return nil
        }
    }
    
    //MARK: - Helper functions
    
    func run() {
        self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func pause() {
        self.session.pause()
    }
    
    func distance(betweenPoints point1: SCNVector3, point2: SCNVector3) -> CGFloat {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        let dz = point2.z - point1.z
        return CGFloat(sqrt(dx*dx + dy*dy + dz*dz))
    }
    
}

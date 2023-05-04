//
//  AreaMeasureVC.swift
//  AR Measure
//
//  Created by banu, pitta on 24/04/23.
//

import Foundation
import UIKit
import ARKit

class AreaMeasureVC: BaseMeasureVC {

    enum MeasureState {
        case lengthCal
        case breadthCal
    }
    
    struct FloorRect {
        var length: CGFloat
        var breadth: CGFloat
        var area: CGFloat {
            get {
                return length * breadth
            }
        }
    }
    
    var floorRect = FloorRect(length: 0, breadth: 0)
    var lengthNodes = NSMutableArray()
    var breadthNodes = NSMutableArray()
    var lineNodes = NSMutableArray()
    var currentState: MeasureState = MeasureState.lengthCal
    var measureMultiplier: CGFloat = 0
    var measureReadingType: String = ""
    
    var allNodePoints: [Any] {
        get {
            return lengthNodes as! [Any] + breadthNodes
        }
    }
    var nodeColor: UIColor {
        get {
            return nodeColor(forState: currentState, alphaComponent: 0.7)
        }
    }
    
   
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var breadthLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Measure Area"
        let button1 = UIBarButtonItem(image: UIImage(named: "reset"), style: .plain, target: self, action: #selector(resetMeasurement))
        let button2 = UIBarButtonItem(image: UIImage(named: "undo"), style: .plain, target: self, action: #selector(undoNodesAction))
        self.navigationItem.rightBarButtonItems = [button1, button2]
        
        sceneView.delegate = self
        lengthLabel.textColor = nodeColor(forState: .lengthCal, alphaComponent: 1)
        breadthLabel.textColor = nodeColor(forState: .breadthCal, alphaComponent: 1)
        if UserDefaults.standard.measureType == .centimeters {
            measureMultiplier = 100
            measureReadingType = "cm"
        } else if UserDefaults.standard.measureType == .meters {
            measureMultiplier = 1
            measureReadingType = "m"
        } else if UserDefaults.standard.measureType == .inches {
            measureMultiplier = 39.37
            measureReadingType = "In"
        }
    }
    
    //MARK: - Helper functions

    private func nodeColor(forState state: MeasureState, alphaComponent: CGFloat) -> UIColor {
        switch state {
        case .lengthCal:
            return UIColor.red.withAlphaComponent(alphaComponent)
        case .breadthCal:
            return UIColor.green.withAlphaComponent(alphaComponent)
        }
    }
    

    private func nodesList(forState state: MeasureState) -> NSMutableArray {
        switch state {
        case .lengthCal:
            return lengthNodes
        case .breadthCal:
            return breadthNodes
        }
    }
    
    func clearScene() {
        removeNodes(fromNodeList: nodesList(forState: .lengthCal))
        removeNodes(fromNodeList: nodesList(forState: .breadthCal))
        removeNodes(fromNodeList: lineNodes)
    }
    
    @objc private func resetMeasurement() {
        clearScene()
        realTimeLineNode?.removeFromParentNode()
        realTimeLineNode = nil
        floorRect = FloorRect(length: 0, breadth: 0)
        currentState = .lengthCal
        lengthLabel.text = "--"
        breadthLabel.text = "--"
        areaLabel.text = "--"
    }
    
    
    @objc func undoNodesAction() {
        if allNodePoints.count > 0 {
            realTimeLineNode?.removeFromParentNode()
            realTimeLineNode = nil
            if breadthNodes.count > 0 {
                removeNodes(fromNodeList: nodesList(forState: .breadthCal))
                breadthLabel.text = "--"
                if lineNodes.count == 2 {
                    lineNodes.removeLastObject()
                }
            } else if lengthNodes.count > 0 {
               resetMeasurement()
            }
        }
    }
    
    
    //MARK: - IBActions
    
    @IBAction func addNodePoint(_ sender: UIButton) {
        
        let pointLocation = view.convert(screenCenterPoint, to: sceneView)
        guard let hitResultPosition = sceneView.hitResult(forPoint: pointLocation)  else {
            return
        }
        
        sender.isUserInteractionEnabled = false
        defer {
            sender.isUserInteractionEnabled = true
        }
        
        if currentState == .breadthCal && allNodePoints.count == 2 {
            let startNode = lengthNodes[0] as! SCNNode
            let endNode = lengthNodes[1]  as! SCNNode
            let hitresultStartPoint = Int("\(hitResultPosition.x)".split(separator: ".").first ?? "") ?? 0
            let startNodePositionX = Int("\(startNode.position.x)".split(separator: ".").first ?? "") ?? 0
            let endNodePositionX = Int("\(endNode.position.x)".split(separator: ".").first ?? "") ?? 0
            if hitresultStartPoint != startNodePositionX && hitresultStartPoint != endNodePositionX {
                displayAlertWith(title: "Position Mismatch", message: "Please keep breadth start point at length start or end point")
                return
            }
        }
        
        if allNodePoints.count >= 4 {
            resetMeasurement()
        }
        let nodes = nodesList(forState: currentState)
        
        let sphere = SCNSphere(color: nodeColor, radius: nodeRadius)
        let node = SCNNode(geometry: sphere)
        node.position = hitResultPosition
        sceneView.scene.rootNode.addChildNode(node)
        
        
        nodes.add(node)
        
        if nodes.count == 1 {
            let realTimeLine = LineNode(from: hitResultPosition,
                                        to: hitResultPosition,
                                        lineColor: nodeColor,
                                        lineWidth: lineWidth)
            realTimeLine.name = measureRealTimeLine
            realTimeLineNode = realTimeLine
            sceneView.scene.rootNode.addChildNode(realTimeLine)
            
        } else if nodes.count == 2 {
            let startNode = nodes[0] as! SCNNode
            let endNode = nodes[1]  as! SCNNode
            
            let measureLine = LineNode(from: startNode.position,
                                       to: endNode.position,
                                       lineColor: nodeColor,
                                       lineWidth: lineWidth)
            sceneView.scene.rootNode.addChildNode(measureLine)
            lineNodes.add(measureLine)
            
            let distance = sceneView.distance(betweenPoints: startNode.position, point2: endNode.position) * measureMultiplier
            
            realTimeLineNode?.removeFromParentNode()
            realTimeLineNode = nil
            
            switch currentState {
            case .lengthCal:
                floorRect.length = distance
                currentState = .breadthCal
                lengthLabel.text = String(format: "%.2f\(measureReadingType)", distance)
            case .breadthCal:
                floorRect.breadth = distance
                breadthLabel.text = String(format: "%.2f\(measureReadingType)", distance)
                areaLabel.text = String(format: "%.2f\(measureReadingType)", floorRect.area)
            }
        }
    }
    
    // MARK: - Helper functions
    
    func displayAlertWith(title: String, message: String, useAction: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(dismiss)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension AreaMeasureVC: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let dotNodes = allNodePoints as! [SCNNode]
        if dotNodes.count > 0, let currentCameraPosition = self.sceneView.pointOfView {
            updateScaleFromCameraForNodes(dotNodes, fromPointOfView: currentCameraPosition)
        }
        
        if let realTimeLineNode = self.realTimeLineNode,
            let hitResultPosition = sceneView.hitResult(forPoint: screenCenterPoint),
            let startNode = self.nodesList(forState: self.currentState).firstObject as? SCNNode {
            realTimeLineNode.updateNode(vectorA: startNode.position, vectorB: hitResultPosition, color: nil)
            
            let distance = sceneView.distance(betweenPoints: startNode.position, point2: hitResultPosition) * measureMultiplier
            let label = currentState == .lengthCal ? lengthLabel : breadthLabel
            DispatchQueue.main.async { [unowned self] in
                label?.text = String(format: "%.2f\(measureReadingType)", distance)
                label?.textColor = self.nodeColor
            }
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .normal:
            break
        default:
            break
        }
    }
    
}

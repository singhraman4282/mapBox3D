//
//  NodeFactory.swift
//  MapboxCELADemo
//
//  Created by Raman Singh on 2018-06-23.
//  Copyright © 2018 Raman Singh. All rights reserved.
//

import UIKit
import CoreLocation
import SceneKit
import MapboxSceneKit
import ARKit

class NodeFactory: NSObject {
    
    private let locationManager = CLLocationManager()
    private let RamansConstantForLat = 111034.840457//70402.2231289
    private let RamansConstantForLon = 72748.1081083//72828.9200356
    private let elevationManager = ElevationManager()
    private let annotationManager = AnnotationManager()
    
//    
    
    
    func createBusNode(lattitude:Double, longitude:Double, name:String, insideTerrainWithLattitude terrainLattitude:Double, insideTerrainWithLongitude terrainLongitude:Double, annotationColor: UIColor) -> SCNNode {
        
//        let latBegin = (self.locationManager.location?.coordinate.latitude)! - (0.07621358526/2)
//        let lonBegin = (self.locationManager.location?.coordinate.longitude)! - (0.12192598544/2)

        let latBegin = terrainLattitude - (0.07621358526/2)
        let lonBegin = terrainLongitude - (0.12192598544/2)
        
        let busNode = SCNNode(geometry: SCNBox(width: 10, height: 30, length: 10, chamferRadius: 0))
        busNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        busNode.position = SCNVector3(-(lonBegin - longitude)*RamansConstantForLon,50.004517,(8462.36328 + ((latBegin - lattitude)*RamansConstantForLat)))
        
        busNode.name = name
        let rotateAction = SCNAction.rotate(by: 2 * CGFloat.pi, around: SCNVector3(0, 0.5, 0), duration: 10)
        let foreverRotation = SCNAction.repeatForever(rotateAction)
        let goUpAction = SCNAction.move(by: SCNVector3(0,500,0), duration: 1)
        let goDownAction = SCNAction.move(by: SCNVector3(0,-500,0), duration: 1)
        let sequence = SCNAction.sequence([goUpAction, goDownAction])
        let foreverSequence = SCNAction.repeatForever(sequence)
//        busNode.runAction(foreverSequence, completionHandler:nil)
        
        let node = self.createText(text: name, textColor: annotationColor, position: SCNVector3(0,40,0), scale: SCNVector3(3,3,3))
        node.runAction(foreverRotation)

        busNode.addChildNode(node)
        busNode.position = SCNVector3(busNode.position.x,30000.0,busNode.position.z)
        
        let moveToElevationAction = SCNAction.move(to: SCNVector3(Double(busNode.position.x),200,Double(busNode.position.z)), duration: 1)
        busNode.runAction(moveToElevationAction)
        
        
//        annotationManager.downloadElevationFromCoordinates(lattitude: lattitude, longitude: longitude) { (json, nil) -> (Void) in
//            if let json = json {
//                if let results = json["results"] as? [[String: Any]] {
//
//                    let moveToElevationAction = SCNAction.move(to: SCNVector3(Double(busNode.position.x),8*self.elevationManager.createElevationFromjSon(json: results),Double(busNode.position.z)), duration: 1)
//                    busNode.runAction(moveToElevationAction)
//
//                }
//
//            }
//        }
        
        
        
        return busNode
    }
    
    
    func createMyPositionNode(elevation:Double) -> SCNNode {
        
        let myPositionNode = SCNNode(geometry: SCNSphere(radius: 10))
        myPositionNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        myPositionNode.position = SCNVector3(8869.88477/2,91.40330505371094*2,8462.36328/2)
        myPositionNode.name = "endSphere"
        
        return myPositionNode
    }
   
    
    func createTerrainNode(lattitude:Double, longitude:Double) -> TerrainNode {
        
        var latToBePlaced = self.locationManager.location?.coordinate.latitude
        var lonToBePlaced = self.locationManager.location?.coordinate.longitude
        
        if lattitude != 0.0 {
            latToBePlaced = lattitude
            lonToBePlaced = longitude
        }
        
        let terrainNode = TerrainNode(minLat: latToBePlaced! - (0.07621358526/2), maxLat: latToBePlaced! + (0.07621358526/2),
                                     minLon: lonToBePlaced! - (0.12192598544/2), maxLon: lonToBePlaced! + (0.12192598544/2))
        
        terrainNode.name = "terrainNode"
        
        return terrainNode
    }
    
    func createText(text: String, textColor: UIColor, position: SCNVector3, scale: SCNVector3) -> SCNNode {
        let text = SCNText(string: text, extrusionDepth: 2)
        text.font = UIFont(name: "AvenirNext-Medium", size: 25)
        
        let material = SCNMaterial()
        material.diffuse.contents = textColor
        text.materials = [material]
        
        let node = SCNNode(geometry: text)
        node.scale = scale
        node.position = position
        
        // rotate at the center of the nodes width and height
        let min = node.boundingBox.min
        let max = node.boundingBox.max
        node.pivot = SCNMatrix4MakeTranslation(
            min.x + /* (+ 0.5 *) */ (max.x - min.x) / 2,
            min.y + /* (+ 0.5 *) */ (max.y - min.y) / 2,
            min.z + /* (+ 0.5 *) */ (max.z - min.z) / 2
        )
        
        node.name = "scoreNode"
        return node
    }
    
    
    
}


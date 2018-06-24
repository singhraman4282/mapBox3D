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
    
    func createBusNode(lattitude:Double, longitude:Double, name:String) -> SCNNode {
        
        let latBegin = (self.locationManager.location?.coordinate.latitude)! - (0.07621358526/2)
        let lonBegin = (self.locationManager.location?.coordinate.longitude)! - (0.12192598544/2)
        
        let busNode = SCNNode(geometry: SCNBox(width: 10, height: 10, length: 30, chamferRadius: 0))
        busNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        busNode.position = SCNVector3(-(lonBegin - longitude)*RamansConstantForLon,380.004517,(8462.36328 + ((latBegin - lattitude)*RamansConstantForLat)))
        print(latBegin-lattitude)
        busNode.name = name
        
        return busNode
    }
    
    
    func createMyPositionNode() -> SCNNode {
        
        let myPositionNode = SCNNode(geometry: SCNSphere(radius: 10))
        myPositionNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        myPositionNode.position = SCNVector3(8869.88477/2,280.004517,8462.36328/2)
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
    
}

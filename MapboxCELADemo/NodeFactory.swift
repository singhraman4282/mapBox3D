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
    private let RamansConstantForLat = 111034.840457
    private let RamansConstantForLon = 72748.1081083
    private let annotationManager = AnnotationManager()
    
    func CreatePlaceNode(lattitude:Double, longitude:Double, name:String, insideTerrainWithLattitude terrainLattitude:Double, insideTerrainWithLongitude terrainLongitude:Double, annotationColor: UIColor) -> SCNNode {
        
        let latBegin = terrainLattitude - (0.07621358526/2)
        let lonBegin = terrainLongitude - (0.12192598544/2)
        
        let placeNode = SCNNode(geometry: SCNBox(width: 10, height: 30, length: 10, chamferRadius: 0))
        placeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        placeNode.position = SCNVector3(-(lonBegin - longitude)*RamansConstantForLon,50.004517,(8462.36328 + ((latBegin - lattitude)*RamansConstantForLat)))
        
        placeNode.name = name
        let rotateAction = SCNAction.rotate(by: 2 * CGFloat.pi, around: SCNVector3(0, 0.5, 0), duration: 10)
        let foreverRotation = SCNAction.repeatForever(rotateAction)

        let node = self.createText(text: name, textColor: annotationColor, position: SCNVector3(0,40,0), scale: SCNVector3(3,3,3))
        node.runAction(foreverRotation)

        placeNode.addChildNode(node)
        placeNode.position = SCNVector3(placeNode.position.x,30000.0,placeNode.position.z)
        
        let moveToElevationAction = SCNAction.move(to: SCNVector3(Double(placeNode.position.x),200,Double(placeNode.position.z)), duration: 1)
        placeNode.runAction(moveToElevationAction)

        return placeNode
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


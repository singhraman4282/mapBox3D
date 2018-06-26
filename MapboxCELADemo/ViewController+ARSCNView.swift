//
//  ViewController+ARSCNView.swift
//  MapBoxCELADemo
//
//  Created by Raman Singh on 2018-06-21.
//  Copyright © 2018 Raman Singh. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

extension ViewController: ARSCNViewDelegate, ARSessionDelegate {

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocusSquare()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.eulerAngles.x = -.pi / 2
        planeNode.isHidden = true
        node.addChildNode(planeNode)
        
        planes[anchor.identifier] = planeNode
        
        DispatchQueue.main.async {
            self.setMessage("")
            if self.terrain == nil {
                self.placeButton?.isHidden = false
                self.moveImage?.isHidden = true
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        planeNode.simdPosition = float3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
        
        planes[anchor.identifier] = planeNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        node.removeFromParentNode()
        planes.removeValue(forKey: anchor.identifier)
        
        if planes.isEmpty {
            DispatchQueue.main.async {
                self.terrain?.removeFromParentNode()
                self.moveImage?.isHidden = false
                self.arView?.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
            }
        }
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        setMessage("Session was interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        setMessage("Session interruption ended")
        
        restartTracking()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        setMessage("Session failed: \(error.localizedDescription)")
        
        restartTracking()
    }
    
    func defaultMaterials() -> [SCNMaterial] {
        let groundImage = SCNMaterial()
        groundImage.diffuse.contents = UIColor.darkGray
        groundImage.name = "Ground texture"
        
        let sideMaterial = SCNMaterial()
        sideMaterial.diffuse.contents = UIColor.darkGray
        //TODO: Some kind of bug with the normals for sides where not having them double-sided has them not show up
        sideMaterial.isDoubleSided = true
        sideMaterial.name = "Side"
        
        let bottomMaterial = SCNMaterial()
        bottomMaterial.diffuse.contents = UIColor.black
        bottomMaterial.name = "Bottom"
        
        return [sideMaterial, sideMaterial, sideMaterial, sideMaterial, groundImage, bottomMaterial]
    }
    
    func restartTracking() {
        terrain?.removeFromParentNode()
        for (_, plane) in planes {
            plane.removeFromParentNode()
        }
        planes.removeAll()
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        
        arView?.session.run(configuration, options: [.removeExistingAnchors])
        arView?.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        arView?.isUserInteractionEnabled = false
        placeButton?.isHidden = true
        moveImage?.isHidden = false
        
        setupFocusSquare()
        
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    // MARK: - Message Helpers
    
    func setMessage(_ message: String) {
        self.messageLabel?.text = message
        self.messageView?.isHidden = message.isEmpty
    }
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            message = "Move the device around to detect flat surfaces."
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        default:
            message = ""
        }
        
        setMessage(message)
    }
    
    
    
    // MARK: - Focus Square
    
    func setupFocusSquare() {
        focusSquare?.isHidden = true
        focusSquare?.removeFromParentNode()
        focusSquare = FocusSquare()
        arView?.scene.rootNode.addChildNode(focusSquare!)
    }
    
    func updateFocusSquare() {
        guard let arView = arView else { return }
        
        if !arView.isUserInteractionEnabled, let result = arView.smartHitTest(screenCenter, infinitePlane: true), let planeAnchor = result.anchor as? ARPlaneAnchor {
            let position: SCNVector3 = SCNVector3(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
            focusSquare?.update(for: position, planeAnchor: planeAnchor, camera: arView.session.currentFrame?.camera)
            focusSquare?.unhide()
        } else {
            focusSquare?.hide()
        }
    }
    
    
    //MARK: - Misc Helpers
   
        var screenCenter: CGPoint {
        let bounds = arView!.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private var session: ARSession {
        return arView!.session
    }

}

//
//  ViewController+gestures.swift
//  MapboxCELADemo
//
//  Created by Raman Singh on 2018-06-23.
//  Copyright © 2018 Raman Singh. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit


extension ViewController: UIGestureRecognizerDelegate {
    // MARK: - UIGestureRecognizer
    
     func setupGestures() {
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        rotate.delegate = self
        arView?.addGestureRecognizer(rotate)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinch.delegate = self
        arView?.addGestureRecognizer(pinch)
        let drag = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        drag.delegate = self
        drag.minimumNumberOfTouches = 1
        drag.maximumNumberOfTouches = 1
        arView?.addGestureRecognizer(drag)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.numberOfTouches == otherGestureRecognizer.numberOfTouches
    }
    
    
    @objc fileprivate func handleDrag(_ gesture: UIRotationGestureRecognizer) {
        guard let terrain = terrain else {
            return
        }
        
        let point = gesture.location(in: gesture.view!)
        if let result = arView?.smartHitTest(point, infinitePlane: true) {
            if let lastDragResult = lastDragResult {
                let vector: SCNVector3 = SCNVector3(result.worldTransform.columns.3.x - lastDragResult.worldTransform.columns.3.x,
                                                    result.worldTransform.columns.3.y - lastDragResult.worldTransform.columns.3.y,
                                                    result.worldTransform.columns.3.z - lastDragResult.worldTransform.columns.3.z)
                terrain.position += vector
            }
            lastDragResult = result
        }
        
        if gesture.state == .ended {
            self.lastDragResult = nil
        }
    }
    
    @objc fileprivate func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard let terrain = terrain else {
            return
        }
        var normalized = (terrain.eulerAngles.y - Float(gesture.rotation)).truncatingRemainder(dividingBy: 2 * .pi)
        normalized = (normalized + 2 * .pi).truncatingRemainder(dividingBy: 2 * .pi)
        if normalized > .pi {
            normalized -= 2 * .pi
        }
        terrain.eulerAngles.y = normalized
        gesture.rotation = 0
    }
    
    
    @objc fileprivate func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let terrain = terrain else {
            return
        }
        if gesture.state == UIGestureRecognizerState.began {
            startScale = terrain.scale.x
        }
        guard let startScale = startScale else {
            return
        }
        let newScale: Float = startScale * Float(gesture.scale)
        terrain.scale = SCNVector3(newScale, newScale, newScale)
        if gesture.state == .ended {
            self.startScale = nil
        }
    }
}

//
//  ViewController.swift
//  MapboxCELADemo
//
//  Created by Raman Singh on 2018-06-21.
//  Copyright © 2018 Raman Singh. All rights reserved.
//

import UIKit
import MapboxSceneKit
import SceneKit
import ARKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var arView: ARSCNView?
    @IBOutlet weak var placeButton: UIButton?
    @IBOutlet weak var moveImage: UIImageView?
    @IBOutlet weak var messageView: UIVisualEffectView?
    @IBOutlet weak var messageLabel: UILabel?
   
    
    
    @IBOutlet var xPosOutlet: UIButton!
    @IBOutlet var yPosOutlet: UIButton!
    @IBOutlet var zPosOutlet: UIButton!
    @IBOutlet var xNegOutlet: UIButton!
    @IBOutlet var yNegOutlet: UIButton!
    @IBOutlet var zNegOutlet: UIButton!
    
    
    let locationManager = CLLocationManager()
    weak var terrain: SCNNode?
    var planes: [UUID: SCNNode] = [UUID: SCNNode]()
    
    let nodeFactory = NodeFactory()
    var focusSquare: FocusSquare?
    var lastDragResult: ARHitTestResult?
    var startScale: Float?
    var cityLattitude = 0.0
    var cityLongitude = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(cityLattitude)
        print(cityLongitude)
        enableBasicLocationServices()
        locationManager.delegate = self
        
        arView!.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        arView!.session.delegate = self
        arView!.delegate = self
        if let camera = arView?.pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
        }
        
        arView!.isUserInteractionEnabled = false
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        restartTracking()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        arView?.session.pause()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    //MARK: - LocationServices
    
    func enableBasicLocationServices() {
       switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted, .denied:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse, .authorizedAlways:
            print((self.locationManager.location?.coordinate.latitude)!)
            print((self.locationManager.location?.coordinate.longitude)!)
            break
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func place(_ sender: AnyObject?) {
        let tapPoint = screenCenter
        var result = arView?.smartHitTest(tapPoint)
        if result == nil {
            result = arView?.smartHitTest(tapPoint, infinitePlane: true)
        }
        
        guard result != nil, let anchor = result?.anchor, let plane = planes[anchor.identifier] else {
            return
        }
        
        insert(on: plane, from: result!)
        arView?.debugOptions = []
        
        self.placeButton?.isHidden = true
    }
    
    private func insert(on plane: SCNNode, from hitResult: ARHitTestResult) {
       
        let terrainNode = nodeFactory.createTerrainNode(lattitude: cityLattitude, longitude: cityLongitude)
        
        let scale = Float(0.333 * hitResult.distance) / terrainNode.boundingSphere.radius
        terrainNode.transform = SCNMatrix4MakeScale(scale, scale, scale)
        terrainNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        terrainNode.geometry?.materials = defaultMaterials()
        arView!.scene.rootNode.addChildNode(terrainNode)
        terrain = terrainNode
        
        
        terrainNode.fetchTerrainHeights(minWallHeight: 50.0, enableDynamicShadows: true, progress: { _, _ in }, completion: {
            NSLog("Terrain load complete")
        })
        
        terrainNode.fetchTerrainTexture("mapbox/satellite-v9", zoom: 14, progress: { _, _ in }, completion: { image in
            NSLog("Texture load complete")
            terrainNode.geometry?.materials[4].diffuse.contents = image
        })
        
        if cityLattitude == 0.0 {
            let endSphere = nodeFactory.createMyPositionNode()
            terrainNode.addChildNode(endSphere)
        }
        

        let redNode0 = nodeFactory.createBusNode(lattitude: 49.129189, longitude: -122.819817, name: "endSphere")
        terrainNode.addChildNode(redNode0)
        
        arView!.isUserInteractionEnabled = true
    }
    
    let moveFactor:Float = 10.0
    
    @IBAction func printPosition(_ sender: UIButton) {
        self.arView?.scene.rootNode.enumerateChildNodes({ (node, _) in
            var terrainPosition = SCNVector3()
            let terrainNode:Any?
            if node.name == "terrainNode" {
//                print("terrainNode is at: \(node.position)")
                print("terrainSize is:\(node.boundingBox)")
//                print(node.geometry?.boundingSphere.center.z)
                terrainPosition = node.position
                terrainNode = node as! TerrainNode
            }
            if node.name == "endSphere" {
                print("node positon:\(node.position)")
//                node.position = SCNVector3(terrainPosition.x + (terrainNode as! TerrainNode).geometry?.boundingSphere,0,0)
            }
        })
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Message Helpers
    
    
    
    
    
    
    
    
    
}

extension ARSCNView {
    func smartHitTest(_ point: CGPoint,
                      infinitePlane: Bool = false,
                      objectPosition: float3? = nil,
                      allowedAlignments: [ARPlaneAnchor.Alignment] = [.horizontal]) -> ARHitTestResult? {
        
        // Perform the hit test.
        let results: [ARHitTestResult]!
        if #available(iOS 11.3, *) {
            results = hitTest(point, types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
        } else {
            results = hitTest(point, types: [.estimatedHorizontalPlane])
        }
        
        // 1. Check for a result on an existing plane using geometry.
        if #available(iOS 11.3, *) {
            if let existingPlaneUsingGeometryResult = results.first(where: { $0.type == .existingPlaneUsingGeometry }),
                let planeAnchor = existingPlaneUsingGeometryResult.anchor as? ARPlaneAnchor, allowedAlignments.contains(planeAnchor.alignment) {
                return existingPlaneUsingGeometryResult
            }
        }
        
        if infinitePlane {
            // 2. Check for a result on an existing plane, assuming its dimensions are infinite.
            //    Loop through all hits against infinite existing planes and either return the
            //    nearest one (vertical planes) or return the nearest one which is within 5 cm
            //    of the object's position.
            let infinitePlaneResults = hitTest(point, types: .existingPlane)
            
            for infinitePlaneResult in infinitePlaneResults {
                if let planeAnchor = infinitePlaneResult.anchor as? ARPlaneAnchor, allowedAlignments.contains(planeAnchor.alignment) {
                    // For horizontal planes we only want to return a hit test result
                    // if it is close to the current object's position.
                    if let objectY = objectPosition?.y {
                        let planeY = infinitePlaneResult.worldTransform.translation.y
                        if objectY > planeY - 0.05 && objectY < planeY + 0.05 {
                            return infinitePlaneResult
                        }
                    } else {
                        return infinitePlaneResult
                    }
                }
            }
        }
        
        // 3. As a final fallback, check for a result on estimated planes.
        return results.first(where: { $0.type == .estimatedHorizontalPlane })
    }
}

fileprivate extension float4x4 {
    /**
     Treats matrix as a (right-hand column-major convention) transform matrix
     and factors out the translation component of the transform.
     */
    var translation: float3 {
        get {
            let translation = columns.3
            return float3(translation.x, translation.y, translation.z)
        }
        set(newValue) {
            columns.3 = float4(newValue.x, newValue.y, newValue.z, columns.3.w)
        }
    }
    
    /**
     Factors out the orientation component of the transform.
     */
    var orientation: simd_quatf {
        return simd_quaternion(self)
    }
    
    /**
     Creates a transform matrix with a uniform scale factor in all directions.
     */
    init(uniformScale scale: Float) {
        self = matrix_identity_float4x4
        columns.0.x = scale
        columns.1.y = scale
        columns.2.z = scale
    }
}



//
//  ElevationManager.swift
//  MapboxCELADemo
//
//  Created by Raman Singh on 2018-06-24.
//  Copyright © 2018 Raman Singh. All rights reserved.
//

import UIKit
import SceneKit

class ElevationManager: NSObject {
    
    func createElevationFromjSon(json recievedDict:[[String: Any]]) -> Double {
        var elevationDouble = 0.0
        if let returnedDict = recievedDict[0] as? [String:Any] {
            if let elevation = returnedDict["elevation"] as? Double {
                elevationDouble = elevation
            }
        }
        return elevationDouble
    }
    
}

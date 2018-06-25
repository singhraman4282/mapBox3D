//
//  APITestViewController.swift
//  MapboxCELADemo
//
//  Created by Raman Singh on 2018-06-23.
//  Copyright © 2018 Raman Singh. All rights reserved.
//

import UIKit

class APITestViewController: UIViewController {

    let annotationManager = AnnotationManager()
    
    var listings = [Annotation]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        annotationManager.downloadAnnotationsFromURL(lattitude: 49.110652, longitude: -122.867261, searchItem: "cafe") { (json, nil) -> (Void) in
            if let json = json {
                
                let allPlaces = json["businesses"] as! [[String : Any]];
                print(allPlaces.count)
                
                for i in 0..<allPlaces.count {
                    var thisCafe = Annotation()
                    var thisDict = allPlaces[i] as? [AnyHashable: Any]
                    
                    let coordinates = thisDict!["coordinates"] as! [AnyHashable : Any]
                    thisCafe.image_url = thisDict!["image_url"] as! String
                    thisCafe.name = thisDict!["name"] as! String
                    
                    self.listings.append(thisCafe)
                    print("place name is \(thisCafe.name)")
                    thisCafe.lattitude = Double(coordinates["latitude"] as! Double)
                    thisCafe.longitude = Double(coordinates["longitude"] as! Double)
                    
//                    print("Lattitude is \(thisCafe.lattitude)")
//                    print("longitude is \(thisCafe.longitude)")
                    
                }
            }
        }
    
    }

    

}

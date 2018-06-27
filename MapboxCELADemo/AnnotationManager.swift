//
//  AnnotationManager.swift
//  MapboxCELADemo
//
//  Created by Raman Singh on 2018-06-25.
//  Copyright © 2018 Raman Singh. All rights reserved.
//

import UIKit
import SceneKit
import CoreLocation

class AnnotationManager: NSObject {
    
    
    let locationManager = CLLocationManager()
    var placeNamesArray = [String]()
    
    func downloadAnnotationsFromURL(lattitude:Double, longitude:Double,searchItem:String, completion: @escaping ([String: Any]?, Error?)->(Void)) {
        let url = URL(string:"https://api.yelp.com/v3/businesses/search?term=\(searchItem)&latitude=\(lattitude)&longitude=\(longitude)")!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        
        request.addValue("Bearer 1Xhul00_71BPzNJS446OOWyN9qCnWnBz9aYEcazRIW7BC8cKENhRFiom9ihm22D9eI7FR8pLLDp7mRUh_Bx7jmq0V5UdsDVGeP3vurbyZ_UGHQZ0KCwt5mI66DPjWnYx", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            guard let data = data else {
                print("no data returned from server \(String(describing: error?.localizedDescription))")
                return
            }
            
            var json: [String: Any]?
            do {
                json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print("json fail")
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("no response returned from server \(String(describing: error))")
                return
            }
            
            guard response.statusCode == 200 else {
                print("an error occurred)")
                return
            }
            
            DispatchQueue.main.async {
                completion(json, error)
            }
            
        }
        task.resume()
    }
    
    func downloadElevationFromCoordinates(lattitude:Double, longitude:Double, completion: @escaping ([String: Any]?, Error?)->(Void)) {
        let url = URL(string: "https://maps.googleapis.com/maps/api/elevation/json?locations=\(lattitude),\(longitude)&key=AIzaSyDkNbhPWaGIlsuHo3l0Qgz7NqlGD9UJSBM")!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            
            guard let data = data else {
                print("no data returned from server \(String(describing: error?.localizedDescription))")
                return
            }
            
            var json: [String: Any]?
            do {
                json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print("json fail")
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("no response returned from server \(String(describing: error))")
                return
            }
            
            guard response.statusCode == 200 else {
                print("an error occurred)")
                return
            }
            
            DispatchQueue.main.async {
                completion(json, error)
            }
        }
        task.resume()
    }
    
    func addAnnotationsToNode(_ terrainNode:SCNNode, annotationType:String, annotationTextColor: UIColor, withTerrainlattitude cityLat:Double, withTerrainLongitude cityLon:Double, usingNodeFactory nodeFactory:NodeFactory) {
        
        var cityLattitude = cityLat
        var cityLongitude = cityLon
        
        if cityLattitude == 0.0 {
            cityLattitude = (self.locationManager.location?.coordinate.latitude)!
            cityLongitude = (self.locationManager.location?.coordinate.longitude)!
        }
        
        var latGrid = cityLat - (0.07621358526/2)
        var lonGrid = cityLon - (0.12192598544/2)
        
        for _ in 0...3 {
            latGrid += 0.03810679263
            for _ in 0...3 {
                lonGrid += 0.06096299272
                if lonGrid>cityLon + (0.12192598544/2) {
                    lonGrid = cityLon + 0.06096299272 - (0.12192598544/2)
                    var listings = [Annotation]()
                    self.downloadAnnotationsFromURL(lattitude: latGrid, longitude: lonGrid, searchItem: annotationType) { (json, nil) -> (Void) in
                        if let json = json {
                            
                            let allPlaces = json["businesses"] as! [[String : Any]];
                            
                            for i in 0..<allPlaces.count {
                                var thisCafe = Annotation()
                                var thisDict = allPlaces[i] as? [AnyHashable: Any]
                                
                                let coordinates = thisDict!["coordinates"] as! [AnyHashable : Any]
                                
                                thisCafe.name = thisDict!["name"] as! String
                                
                                listings.append(thisCafe)
                                thisCafe.lattitude = Double(coordinates["latitude"] as! Double)
                                thisCafe.longitude = Double(coordinates["longitude"] as! Double)
                                
                                let cafeNode = nodeFactory.CreatePlaceNode(lattitude: thisCafe.lattitude, longitude: thisCafe.longitude, name: thisCafe.name, insideTerrainWithLattitude: cityLattitude, insideTerrainWithLongitude: cityLongitude, annotationColor: annotationTextColor)
                                
                                if (thisCafe.lattitude > cityLattitude-(0.07621358526/2) && (thisCafe.lattitude < cityLattitude+(0.07621358526/2))) && (thisCafe.longitude > cityLongitude - (0.12192598544/2) && thisCafe.lattitude < cityLattitude+(0.07621358526/2)) && (thisCafe.longitude < cityLongitude + (0.12192598544/2)) {
                                    
                                    if !self.placeNamesArray.contains(thisCafe.name) {
                                        terrainNode.addChildNode(cafeNode)
                                        self.placeNamesArray.append(thisCafe.name)
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        }
        
    }
    
    
}

//
//  AnnotationManager.swift
//  MapboxCELADemo
//
//  Created by Raman Singh on 2018-06-25.
//  Copyright © 2018 Raman Singh. All rights reserved.
//

import UIKit
import SceneKit

class AnnotationManager: NSObject {
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
    
    func addAnnotationsToNode(_ terrainNode:SCNNode) {
        
    }
    
    
}

//
//  WelcomeViewController.swift
//  MapboxCELADemo
//
//  Created by Raman Singh on 2018-06-24.
//  Copyright © 2018 Raman Singh. All rights reserved.
//

import UIKit
import GooglePlaces

class WelcomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    var cityArray = [String]()
    var cityDict = ["Current Location":["Longitude":0.0, "Lattitude":0.0],
                    "Vancouver":["Lattitude":49.2834001, "Longitude":-123.1197239],
                    "Mount Everest": ["Lattitude":27.9630178, "Longitude":86.8871219],
                    "Great Wall of China": ["Lattitude":40.4315283, "Longitude":116.5677432],
                    "São Paulo": ["Lattitude":-23.5912853, "Longitude":-46.6613061],
                    "The Roman Colosseum": ["Lattitude":41.8902102, "Longitude":12.4900422],
                    "Whistler":["Lattitude":50.0935463, "Longitude":-122.9945057],
                    "Toronto":["Lattitude":43.6425701, "Longitude":-79.3892455],
                    "Pyongyang, North Korea":["Lattitude":39.0292506, "Longitude":125.6720721],
                    "Custom Location":["Lattitude":0.0, "Longitude":0.0]
        
        
    ]
    var selectedCity = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cityArray = Array(cityDict.keys)
        cityArray.insert(cityArray.remove(at: cityArray.index(of: "Current Location")!), at: 0)
        cityArray.insert(cityArray.remove(at: cityArray.index(of: "Custom Location")!), at: 1)
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44.0;
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        cell.cityLabel.text = cityArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCity = cityArray[indexPath.row]
        
        if selectedCity != "Custom Location" {
        performSegue(withIdentifier: "brood", sender: self)
        } else {
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            present(autocompleteController, animated: true, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "brood" {
            if let arViewController = segue.destination as? ViewController {
                cityLattitude = cityDict[selectedCity]!["Lattitude"]!
                cityLongitude = cityDict[selectedCity]!["Longitude"]!
                if selectedCity != "Current Location" {
                cityName = selectedCity
                }
            }
        }
    }
    
    
    func moveMe() {
        print("voila")
        self.performSegue(withIdentifier: "brood", sender: self)
    }

}

extension WelcomeViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        print("Place latitude: \(place.coordinate.latitude)")
        print("Place longitude: \(place.coordinate.longitude)")
        
//        cityDict[place.name] = ["Lattitude":place.coordinate.latitude, "Longitude":place.coordinate.longitude]
//        selectedCity = place.name
        dismiss(animated: true, completion: nil)
        
//        cityArray = Array(cityDict.keys)
//        cityArray.insert(cityArray.remove(at: cityArray.index(of: "Current Location")!), at: 0)
//        cityArray.insert(cityArray.remove(at: cityArray.index(of: "Custom Location")!), at: 1)
//        tableView.reloadData()
//        moveMe()
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            var nextViewController = storyboard.instantiateViewController(withIdentifier: "ARViewController")
        
        cityLattitude = place.coordinate.latitude
        cityLongitude = place.coordinate.longitude
        cityName = place.name
        
        
            
        present(nextViewController, animated: true, completion: nil)

        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}


var cityLattitude = 0.0
var cityLongitude = 0.0
var cityName = ""




//
//  WelcomeViewController.swift
//  MapboxCELADemo
//
//  Created by Raman Singh on 2018-06-24.
//  Copyright © 2018 Raman Singh. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    var cityArray = [String]()
    let cityDict = ["Current Location":["Longitude":0.0, "Lattitude":0.0],
                    "Vancouver":["Lattitude":49.2834001, "Longitude":-123.1197239],
                    "Mount Everest": ["Lattitude":27.9630178, "Longitude":86.8871219],
                    "Great Wall of China": ["Lattitude":40.4315283, "Longitude":116.5677432],
                    "São Paulo": ["Lattitude":-23.5912853, "Longitude":-46.6613061],
                    "The Roman Colosseum": ["Lattitude":41.8902102, "Longitude":12.4900422],
                    
        
        
        
    ]
    var selectedCity = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cityArray = Array(cityDict.keys)
        cityArray.insert(cityArray.remove(at: cityArray.index(of: "Current Location")!), at: 0)
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
        print(selectedCity)
        performSegue(withIdentifier: "brood", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "brood" {
            if let arViewController = segue.destination as? ViewController {
                arViewController.cityLattitude = cityDict[selectedCity]!["Lattitude"]!
                arViewController.cityLongitude = cityDict[selectedCity]!["Longitude"]!
            }
        }
    }
    

}

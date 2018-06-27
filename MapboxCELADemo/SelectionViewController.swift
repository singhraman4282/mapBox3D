//
//  SelectionViewController.swift
//  MapboxCELADemo
//
//  Created by Raman Singh on 2018-06-27.
//  Copyright © 2018 Raman Singh. All rights reserved.
//

import UIKit
import GooglePlaces

class SelectionViewController: UIViewController {
    
    
    //MARK: IBActions
    @IBAction func currentLocationClicked(_ sender: UIButton) {
        cityLattitude = 0.0
        cityLongitude = 0.0
        cityName = ""
        goToARViewController()
    }
    
    @IBAction func customLocationClicked(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func goToARViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "ARViewController")
        present(nextViewController, animated: true, completion: nil)
    }
    
    
    
    
    
}

extension SelectionViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
        cityLattitude = place.coordinate.latitude
        cityLongitude = place.coordinate.longitude
        cityName = place.name
        goToARViewController()
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

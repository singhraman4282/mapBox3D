//
//  APITestViewController.swift
//  MapboxCELADemo
//
//  Created by Raman Singh on 2018-06-23.
//  Copyright © 2018 Raman Singh. All rights reserved.
//

import UIKit

class APITestViewController: UIViewController {

    var x = 0
    var y = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for _ in 0...3 {
            x+=1
            for _ in 0...3 {
                y+=1
                if y>4 {
                    y=1
                }
                print("\(x), \(y)")
            }
        }
        
        
        
        
        
        
        
    
    }

    

}

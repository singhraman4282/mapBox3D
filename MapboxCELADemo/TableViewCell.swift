//
//  TableViewCell.swift
//  MapboxCELADemo
//
//  Created by Raman Singh on 2018-06-24.
//  Copyright © 2018 Raman Singh. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var cityLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

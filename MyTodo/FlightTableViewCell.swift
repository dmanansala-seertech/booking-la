//
//  FlightTableViewCell.swift
//  MyTodo
//
//  Created by Diego Karlo Manansala on 13/07/2018.
//  Copyright © 2018 Diego Karlo Manansala. All rights reserved.
//

import UIKit

class FlightTableViewCell: UITableViewCell {

    @IBOutlet weak var flightName: UILabel!
    @IBOutlet weak var flightDetails: UILabel!
    @IBOutlet weak var flightDestination: UILabel!
    @IBOutlet weak var departureTime: UILabel!
    @IBOutlet weak var arrivalTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
}

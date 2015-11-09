//
//  ResponseTableViewCell.swift
//  Squad Up
//
//  Created by Zain Manji on 9/24/15.
//  Copyright (c) 2015 Zeen Labs. All rights reserved.
//

import UIKit

class ResponseTableViewCell: UITableViewCell {

//    @IBOutlet var goingResponseButton: UIButton!
//    @IBOutlet var notGoingResponseButton: UIButton!
    @IBOutlet var cancelEventButton: UIButton!
    @IBOutlet var editEventButton: UIButton!
    
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var endTimeLabel: UILabel!
    @IBOutlet var locationButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

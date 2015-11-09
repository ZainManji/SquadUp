//
//  EventsTableViewCell.swift
//  Squad Up
//
//  Created by Zain Manji on 8/17/15.
//  Copyright (c) 2015 Zeen Labs. All rights reserved.
//

import UIKit

class EventsTableViewCell: UITableViewCell {
    
    @IBOutlet var responseImage: UIImageView!
    @IBOutlet var eventName: UILabel!
    @IBOutlet var eventTime: UILabel!
    @IBOutlet var numPeopleGoing: UILabel!
    @IBOutlet var goingButton: UIButton!
    @IBOutlet var notGoingButton: UIButton!
    @IBOutlet var removeEventButton: UIButton!
    
    @IBOutlet var cancelledLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

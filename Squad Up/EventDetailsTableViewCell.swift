//
//  EventDetailsTableViewCell.swift
//  Squad Up
//
//  Created by Zain Manji on 9/23/15.
//  Copyright (c) 2015 Zeen Labs. All rights reserved.
//

import UIKit

class EventDetailsTableViewCell: UITableViewCell {

    @IBOutlet var eventNameLabel: UILabel!
//    @IBOutlet var timeLabel: UILabel!
//    @IBOutlet var endTimeLabel: UILabel!
//    @IBOutlet var locationButton: UIButton!
    @IBOutlet var eventCreatorLabel: UILabel!
    
    @IBOutlet var goingButton: UIButton!
    @IBOutlet var notGoingButton: UIButton!
    @IBOutlet var invitedPeopleButton: UIButton!
    
    @IBOutlet var cancelledLabel: UILabel!
    
    // Response buttons
    @IBOutlet var goingResponseButton: UIButton!
    @IBOutlet var notGoingResponseButton: UIButton!
    
    @IBOutlet var helperView: UIView!
    @IBOutlet var blastButton: UIButton!
    @IBOutlet var numGoingImage: UIImageView!
    @IBOutlet var numNotGoingImage: UIImageView!
    @IBOutlet var numInvitedImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

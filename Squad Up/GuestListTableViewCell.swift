//
//  GuestListTableViewCell.swift
//  Squad Up
//
//  Created by Zain Manji on 8/24/15.
//  Copyright (c) 2015 Zeen Labs. All rights reserved.
//

import UIKit

class GuestListTableViewCell: UITableViewCell {
    
    @IBOutlet var goingFriendLabel: UILabel!
    @IBOutlet var notGoingFriendLabel: UILabel!
    @IBOutlet var invitedFriendLabel: UILabel!
    @IBOutlet var notGoingProfilePic: UIImageView!
    @IBOutlet var goingProfilePic: UIImageView!
    @IBOutlet var invitedProfilePic: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

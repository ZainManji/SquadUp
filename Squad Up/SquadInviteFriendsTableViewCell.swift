//
//  SquadInviteFriendsTableViewCell.swift
//  Squad Up
//
//  Created by Zain Manji on 11/8/15.
//  Copyright © 2015 Zeen Labs. All rights reserved.
//



import UIKit

class SquadInviteFriendsTableViewCell: UITableViewCell {
    
    @IBOutlet var friendName: UILabel!
    @IBOutlet var invitedSymbol: UIButton!
    @IBOutlet var friendImage: UIImageView!

    var objectId: String = ""
    var friend:Friend?
    var friendIndex:Int?
    var invited:Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


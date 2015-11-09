//
//  CommentsTableViewCell.swift
//  Squad Up
//
//  Created by Zain Manji on 9/23/15.
//  Copyright (c) 2015 Zeen Labs. All rights reserved.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {

    @IBOutlet var username: UILabel!
    @IBOutlet var message: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var profilePic: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  CommentTableViewCell.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 7/29/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var username_leading_constraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

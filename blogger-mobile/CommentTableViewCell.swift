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
    
    
    @IBAction func replyAction(_ sender: Any) {
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.indentationWidth = CGFloat(20)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

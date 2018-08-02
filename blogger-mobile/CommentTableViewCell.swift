//
//  CommentTableViewCell.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 7/29/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell, UITextViewDelegate  {
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var username_leading_constraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    
    var current_size: CGFloat! = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.delegate = self
        textView.addDoneOnKeyboardWithTarget(self, action: #selector(self.doneAction(_:)), shouldShowPlaceholder: true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @objc func doneAction(_ sender: UITextView) {
        endEditing(true)
        replyButton.sendActions(for: .touchUpInside)
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        var frame = textView.frame
        frame.size.height = textView.contentSize.height
        textView.frame = frame
        
        replyButton.frame.size.height = textView.contentSize.height
        //self.frame.size.height = textView.contentSize.height > self.current_size ? self.frame.size.height+textView.contentSize.height  : self.frame.size.height-textView.contentSize.height
        
        
        //self.current_size = textView.contentSize.height
        
    }
}

//
//  CommentsViewController.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 7/29/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var comments: [Comment]! = []
    var post: Post! = nil
    var user: User! = nil
    
    let cellReuseIdentifier = "cell"
    let cellSpacingHeight: CGFloat = 20
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var postView: UITableView!
    @IBOutlet weak var commentsView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var commentButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.cornerRadius = 15
        
        textView.addDoneOnKeyboardWithTarget(self, action: #selector(self.doneAction(_:)), shouldShowPlaceholder: true)
        
        textView.delegate = self
        
        loading.isHidden = false
        loading.startAnimating()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.hideKeyboardWhenTappedAround()
        
        
        if (post != nil) {
            postView.dataSource = self
            postView.delegate = self
            postView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            
            dump(post)
            //get the comments for this post
            Request.get("\(BaseParams.url)/api/fetch_comments/\(self.post.id)") { (json) in
                DispatchQueue.main.async {
                    self.loading.isHidden = true
                }
                
                let success = json["success"] as! Bool
                if (success) {
                    var comments: [Comment] = []
                    for comment in json["comments"] as! [[String:Any]] {
                        comments.append(Comment(comment))
                    }
                    
                    print("finished parsing comments. here they are: ")
                    dump(comments)
                    self.comments = comments
                    
                    DispatchQueue.main.async {
                        self.commentsView.dataSource = self
                        self.commentsView.delegate = self
                        self.commentsView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
                    }
                    
                }
                
                
                
                
            }
        }
        
    }
    
    
    @IBAction func commentAction(_ sender: Any) {
        let postData: [String: Any] = [
            "token": user.token,
            "comment": self.textView!.text!,
            "parent": 0,
            "pid": self.post.id,
            "indentLevel": 0
        ]
        
        self.sendCommentRequest(postData)
        
        textView.text = ""
    }
    
    @objc func doneAction(_ sender: UITextView) {
        self.view.endEditing(true)
        commentButton.sendActions(for: .touchUpInside)
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        var frame = textView.frame
        frame.size.height = textView.contentSize.height
        textView.frame = frame
        
        commentButton.frame.size.height = textView.contentSize.height
        //self.frame.size.height = textView.contentSize.height > self.current_size ? self.frame.size.height+textView.contentSize.height  : self.frame.size.height-textView.contentSize.height
        
        
        //self.current_size = textView.contentSize.height
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        if (tableView == self.commentsView) {
//            return 150;
//        }
//
//        return 100;
//    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == self.commentsView ? self.comments.count : 1
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView == self.postView ? cellSpacingHeight : 0
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.postView {
            let headerView = UIView()
            headerView.backgroundColor = UIColor.clear
            return headerView
        }
        
        return UIView()
        
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell: UITableViewCell;
        if (tableView == self.commentsView) {
            let cell = (self.commentsView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentTableViewCell)
            //cell = (self.postView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?)!
            
            cell.indentationLevel = self.comments[indexPath.row].indentLevel
            
            /*
            var html = "<p><b>\(self.comments[indexPath.row].username)</b></p>"

            html += self.comments[indexPath.row].comment


            cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
            cell.textLabel?.numberOfLines = 0;
            cell.textLabel?.attributedText = html.htmlToAttributedString
            */

            
   
            /*
            let button : UIButton = UIButton(type: UIButtonType.custom) as UIButton
            button.frame = CGRect(x: 40, y: 60, width: 100, height: 24)
            button.center = CGPoint(x: CGFloat(cell.indentationLevel) * cell.indentationWidth, y: 80.0)
            button.setTitle("Reply", for: UIControlState.normal)
            button.setTitleColor(UIColor.black, for: UIControlState.normal)
            button.titleLabel!.font = UIFont(name: button.titleLabel!.font.fontName, size: 10.0)
            cell.addSubview(button)
            */
            
            // add border and color
            cell.backgroundColor = UIColor.white
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.layer.borderWidth = 0

            cell.clipsToBounds = true
        
            
            cell.username.attributedText = "<b>\(self.comments[indexPath.row].username)</b>".htmlToAttributedString

            cell.comment.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.comment.numberOfLines = 0
            cell.comment.attributedText = self.comments[indexPath.row].comment.htmlToAttributedString
            
            cell.username.sizeToFit()
            cell.comment.sizeToFit()
            
            cell.textView.layer.borderWidth = 1.0
            cell.textView.layer.borderColor = UIColor.gray.cgColor
            cell.textView.layer.cornerRadius = 15.0
            
            
            //cell.textView.translatesAutoresizingMaskIntoConstraints = false
            //cell.textView.isScrollEnabled = false
            //cell.textView.delegate = self
            
            
            
//            cell.replyButton.frame.origin.x = cell.replyButton.frame.origin.x + (CGFloat(cell.indentationLevel)*cell.indentationWidth)
//            cell.comment.frame.origin.x = cell.comment.frame.origin.x + (CGFloat(cell.indentationLevel)*cell.indentationWidth)
//            cell.username.frame.origin.x = cell.username.frame.origin.x + (CGFloat(cell.indentationLevel)*cell.indentationWidth)
            cell.username_leading_constraint.constant = CGFloat(cell.indentationLevel)*cell.indentationWidth
            
            
            cell.replyButton.tag = indexPath.row
            cell.replyButton.addTarget(self, action: #selector(CommentsViewController.replyAction), for: .touchUpInside)
            
            
            let view = UIView()
            view.backgroundColor = UIColor.white
            cell.selectedBackgroundView = view
            
            return cell
            
        }
        else {
            let cell = (self.postView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?)!
            
            var html = "<p>\(self.post.created_at)</p>"
            for image in self.post.images {
                html += "<p><img src='\(image)' width='200'></p>"
            }
            html += self.post.post
            html += self.post.edited ? "<p style='font-size:12px'><i>(Edited on \(self.post.updated_at)</i></p>" : ""
            
            let pictureURL = BaseParams.url == "http://localhost:3000" ? URL(string: "http://localhost:3000/\(self.post.avatar)") : URL(string: self.post.avatar)
            
            var catPicture: UIImage;
            
            if let pictureData = NSData(contentsOf: pictureURL! as URL) {
                catPicture = UIImage(data: pictureData as Data)!
                cell.imageView?.layer.cornerRadius = 40
            }
            else {
                catPicture = UIImage(named: "user_icon")!
            }
            
            cell.imageView?.layer.masksToBounds = true
            cell.imageView?.image = catPicture
            
            cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
            cell.textLabel?.numberOfLines = 0;
            cell.textLabel?.attributedText = html.htmlToAttributedString
            
            // add border and color
            cell.backgroundColor = UIColor.white
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 20
            cell.clipsToBounds = true
            
            let view = UIView()
            view.backgroundColor = UIColor.white
            cell.selectedBackgroundView = view
            
            return cell
            
            
        }
        
    }

    func sendCommentRequest(_ postData: [String: Any]) {
        Request.post("\(BaseParams.url)/api/post_comment", postData, ["Authorization": user.token]) { json in
            let success = json["success"] as! Bool
            if (success) {
                print("dumping the contents of json")
                dump(json["comment"])
                let comment = Comment(json["comment"] as! [String: Any])
                
                print("dumping the contents of comment")
                dump(comment)
                
                if (comment.parent == 0) {
                    self.comments.append(comment)
                    
                    print("current comment count is: \(self.comments.count)")
                    DispatchQueue.main.async {
                        self.commentsView.reloadData()
                    }
                }
                else {
                    for (index, element) in self.comments.enumerated() {
                        if (element.id == comment.parent) {
                            if ((index+1) < self.comments.count) {
                                self.comments.insert(comment, at:index+1)
                            }
                            else {
                                self.comments.append(comment)
                            }
                            
                            DispatchQueue.main.async {
                                self.commentsView.reloadData()
                            }
                            break
                        }
                    }
                }
                
                
            }
            
        }
    }
    
    @objc func replyAction(sender: UIButton) {
        print("you clicked on the reply button for comment \(self.comments[sender.tag].id)")
        let cell: CommentTableViewCell = self.commentsView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! CommentTableViewCell
        
        let postData: [String: Any] = [
            "comment": cell.textView!.text!,
            "parent": self.comments[sender.tag].id,
            "pid": self.post.id,
            "indentLevel": self.comments[sender.tag].indentLevel+1
        ]

        self.sendCommentRequest(postData)
        
        cell.textView!.text = ""
        
    }
    
    
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.commentsView) {
            print("you clicked on comment \(comments[indexPath.row].id)")
            /*
            let storyboard = UIStoryboard(name: "main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CommentsReplyController")
            */
        }
       
    }
}

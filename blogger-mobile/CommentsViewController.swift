//
//  CommentsViewController.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 7/29/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var comments: [Comment]! = nil
    var post: Post! = nil
    var user: User! = nil
    
    let cellReuseIdentifier = "cell"
    let cellSpacingHeight: CGFloat = 20
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var postView: UITableView!
    @IBOutlet weak var commentsView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        loading.isHidden = false
        loading.startAnimating()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        
        
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
            
//            cell.replyButton.frame.origin.x = cell.replyButton.frame.origin.x + (CGFloat(cell.indentationLevel)*cell.indentationWidth)
//            cell.comment.frame.origin.x = cell.comment.frame.origin.x + (CGFloat(cell.indentationLevel)*cell.indentationWidth)
//            cell.username.frame.origin.x = cell.username.frame.origin.x + (CGFloat(cell.indentationLevel)*cell.indentationWidth)
            cell.username_leading_constraint.constant = CGFloat(cell.indentationLevel)*cell.indentationWidth
            
            
            cell.replyButton.tag = self.comments[indexPath.row].id
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
    
    @objc func replyAction(sender: UIButton) {
        print("you clicked on the reply button for comment \(sender.tag)")
        
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

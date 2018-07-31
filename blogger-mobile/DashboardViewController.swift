//
//  VerticalViewController.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 5/5/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newPostButton: UIButton!
    @IBOutlet weak var insertImageButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    
    var user: User? = nil
    var posts: [Post]? = nil
    var password: String? = nil
    
    let cellReuseIdentifier = "cell"
    let cellSpacingHeight: CGFloat = 20
    
    func htmlToFormattedText(_ html: String) -> NSAttributedString {

//        let attrStr = try NSAttributedString(
//            data: html.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
//            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
//            documentAttributes: nil)
        
        if let attrStr = try? NSAttributedString(data: Data(html.utf8), options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            return attrStr
        }
        return NSAttributedString()
    }
    
    
    
    @IBAction func logoutAction(_ sender: Any) {
        BaseParams.keychain["token"] = nil
        self.user = nil
        self.posts = nil
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func chatAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatListViewController") as! ChatListViewController
        
        if let user = self.user {
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
    @IBAction func newPostAction(_ sender: Any) {
        //now transfer to new post view
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewPostController") as! NewPostViewController
        
        print("token: \(self.user!.token)")
        
        vc.user = self.user!
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()

        self.newPostButton.setBackgroundImage(UIImage(named: "new_post"), for: UIControlState.normal)
        self.insertImageButton.setBackgroundImage(UIImage(named: "photo_upload"), for: UIControlState.normal)
        self.settingsButton.setBackgroundImage(UIImage(named: "settings"), for: UIControlState.normal)
        self.logoutButton.setBackgroundImage(UIImage(named: "logout"), for: UIControlState.normal)
        self.chatButton.setBackgroundImage(UIImage(named: "chat"), for: UIControlState.normal)
        
        if (self.posts != nil) {
            print("posts are not nil, as should be expected")
            
            self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
            tableView.delegate = self
            tableView.dataSource = self
        }
        else {
            print("wtf why are posts nil")
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    // MARK: - Table View delegate methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.posts!.count
    }
    
    // There is just one row in every section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = (self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?)!
        
        // note that indexPath.section is used rather than indexPath.row
        
        //add the date and number of comments to the post
        var html = "<p>\(self.posts![indexPath.section].created_at)</p>"
        for image in self.posts![indexPath.section].images {
            html += "<p><img src='\(image)' width='200'></p>"
        }
        html += self.posts![indexPath.section].post
        html += "<p style='font-size:12px'>\(self.posts![indexPath.section].num_comments) Comments</p>"
        html += self.posts![indexPath.section].edited ? "<p style='font-size:12px'><i>(Edited on \(self.posts![indexPath.section].updated_at)</i></p>" : ""
        
        //get the avatar and display it now
        let pictureURL = BaseParams.url == "http://localhost:3000" ? URL(string: "http://localhost:3000/\(self.posts![indexPath.section].avatar)") : URL(string: self.posts![indexPath.section].avatar)
        
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
        
        return cell
    }
    

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // note that indexPath.section is used rather than indexPath.row
        print("You tapped cell number \(indexPath.section).")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
        
        vc.post = self.posts![indexPath.section]
        vc.user = self.user
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}


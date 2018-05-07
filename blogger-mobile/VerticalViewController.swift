//
//  VerticalViewController.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 5/5/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

import UIKit

class VerticalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newPostImage: UIImageView!
    @IBOutlet weak var logOutImage: UIImageView!
    @IBOutlet weak var insertImage: UIImageView!
    
    var user: User? = nil
    var posts: [Post]? = nil
    let url = "http://localhost:3000"
    
    let cellReuseIdentifier = "cell"
    let cellSpacingHeight: CGFloat = 20
    
    func htmlToFormattedText(html: String) -> NSAttributedString {
        do {
            let attrStr = try NSAttributedString(
                data: html.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
                options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                documentAttributes: nil)
            return attrStr;
        } catch let error {
            print(error)
        }
        
        return NSAttributedString()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newPostImage.image = UIImage(named: "new_post")
        self.insertImage.image = UIImage(named: "photo_upload")
        self.logOutImage.image = UIImage(named: "logout")
        
        // Do any additional setup after loading the view.
        if (self.posts != nil) {
//            for post in self.posts! {
//                print(post.post)
//            }
            
            self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
            tableView.delegate = self
            tableView.dataSource = self
        }
        else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ViewController")
            
            self.navigationController?.pushViewController(vc, animated: true)
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
        
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // note that indexPath.section is used rather than indexPath.row
        
        //add the date and number of comments to the post
        var html = "<p>\(self.posts![indexPath.section].created_at)</p>"
        html += self.posts![indexPath.section].post
        html += "<p style='font-size:12px'>\(self.posts![indexPath.section].num_comments) Comments</p>"
        html += self.posts![indexPath.section].edited ? "<p style='font-size:12px'><i>(Edited on \(self.posts![indexPath.section].updated_at)</i></p>" : ""
        
        //get the avatar and display it now
        let pictureURL = URL(string: self.url + "/" + self.posts![indexPath.section].avatar)
        let pictureData = NSData(contentsOf: pictureURL! as URL)
        let catPicture = UIImage(data: pictureData! as Data)
        
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.layer.cornerRadius = 40
        cell.imageView?.image = catPicture
        
        
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
        cell.textLabel?.numberOfLines = 0;
        cell.textLabel?.attributedText = self.htmlToFormattedText(html: html)
        
        
        
        // add border and color
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        
        return cell
    }
    
//    func formatDate(date: String) -> String {
//        let dateFormatterGet = DateFormatter()
//        dateFormatterGet.dateFormat = "yyyy-dd-mm HH:mm:ss.z"
//        let dateFormatterPrint = DateFormatter()
//
//        dateFormatterPrint.dateFormat = "MMM DD, yyyy"
//
//        if let formatted_date = dateFormatterGet.date(from: date) {
//            return dateFormatterPrint.string(from: formatted_date)
//        }
//
//        return ""
//    }
    
    
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // note that indexPath.section is used rather than indexPath.row
        print("You tapped cell number \(indexPath.section).")
    }
    
}


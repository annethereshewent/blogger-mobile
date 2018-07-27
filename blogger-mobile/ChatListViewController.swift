//
//  ChatViewController.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 7/22/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

import UIKit
import SocketIO

class ChatListViewController: BaseController, UITableViewDelegate, UITableViewDataSource {
    
    var user: User? = nil
    var friends: [Friend]? = nil
    
    let cellReuseIdentifier = "cell"
    let cellSpacingHeight: CGFloat = 0
    let manager: SocketManager = SocketManager(socketURL: URL(string: "https://blogger243chat.herokuapp.com")!, config: [.log(true), .compress])
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tableView.isHidden = true
        self.activitySpinner.startAnimating()
        activitySpinner.isHidden = false
        
        // Do any additional setup after loading the view.
        if let user = user {
            let socket = manager.defaultSocket
            
            socket.on(clientEvent: .connect) {data, ack in
                print("socket connected")
                socket.emit("list")
            }
            
            socket.on("list") { data, ack in
                socket.emit("user-list", [
                    "username": user.username,
                    "avatar": user.avatar
                ])
            }
            
            socket.on("user-list") { user, ack in
                //later on we will do stuff to indicate that the user is online.
            }
    
            
            socket.connect()
        
            Request.get("\(self.url)/api/fetch_friends?token=\(user.token)") { (json) in
                self.friends = []
                for friend in json["friends"] as! [Any] {
                    self.friends!.append(Friend(json: friend as! [String: Any]))
                }

                print("received friends:")
                for friend in self.friends! {
                    print(friend)
                }



                DispatchQueue.main.async {
                    self.tableView.isHidden = false
                    self.activitySpinner.isHidden = true

                    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellReuseIdentifier)
                    self.tableView.delegate = self
                    self.tableView.dataSource = self

                    self.tableView.reloadData()

                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
                }

            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Table View delegate methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.friends!.count
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
        
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
        cell.textLabel?.numberOfLines = 0;
        cell.textLabel?.text = self.friends![indexPath.section].username
        
        let pictureURL = URL(string: self.friends![indexPath.section].avatar)
    
        var catPicture: UIImage
        
        if let pictureData = NSData(contentsOf: pictureURL! as URL) {
            catPicture = UIImage(data: pictureData as Data)!
            cell.imageView?.layer.cornerRadius = 40
        }
        else {
            catPicture = UIImage(named: "user_icon")!
        }
        
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.image = catPicture
        
        // add border and color
        cell.backgroundColor = UIColor.lightGray
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 0
        cell.clipsToBounds = true
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // note that indexPath.section is used rather than indexPath.row
        print("you tapped on friend:\(self.friends![indexPath.section].username)")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        if let user = self.user {
            vc.user = user
            vc.friend = self.friends![indexPath.section]
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

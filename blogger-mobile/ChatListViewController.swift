//
//  ChatListViewController.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 7/22/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

import UIKit
import SocketIO

struct UserSection: Comparable {
    var char: String
    var users: [Friend]
    
    static func < (lhs: UserSection, rhs: UserSection) -> Bool {
        return lhs.char < rhs.char
    }
    
    static func == (lhs: UserSection, rhs: UserSection) -> Bool {
        return lhs.char == rhs.char
    }
}

class ChatListViewController: UITableViewController {
    
    var user: User? = nil
    var friends: [Friend]? = nil
    var sections: [UserSection] = []
    var socket: SocketIOClient! = nil

    let cellReuseIdentifier = "cell"
    let cellSpacingHeight: CGFloat = 10
    let manager: SocketManager = SocketManager(socketURL: URL(string: BaseParams.chat_url)!, config: [.log(true), .compress])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Do any additional setup after loading the view.
        if let user = user {
            socket = manager.defaultSocket
            
            
            socket.on(clientEvent: .connect) {data, ack in
                print("socket connected")
                self.socket.emit("login", ["username": user.username, "avatar": user.avatar])
                self.socket.emit("list")
            }
            
            socket.on("list") { data, ack in
                self.socket.emit("user-list", [
                    "username": user.username,
                    "avatar": user.avatar
                ])
            }
            
            socket.on("user-list") { data, ack in
               
                //first check if the user received is in our list of users
                let user = data[0] as! [String: Any]
                let username = user["username"] as! String
                
                print("user-list received for \(username)")
                
                let cells = self.tableView.visibleCells as! Array<UserTableViewCell>
                for cell in cells {
                    if cell.username.text == username {
                        cell.status.image = UIImage(named: "online")
                        break
                    }
                }
            }
            socket.on("logout") { data, ack in
                let user = data[0] as! String
                
                let cells = self.tableView.visibleCells as! Array<UserTableViewCell>
                for cell in cells {
                    if cell.username.text == user {
                        cell.status.image = nil
                        break
                    }
                }
            }
            
            socket.connect()
        
            Request.get("\(BaseParams.url)/api/fetch_friends", ["Authorization": user.token]) { (json) in
                self.friends = []
                for friend in json["friends"] as! [Any] {
                    self.friends!.append(Friend(json: friend as! [String: Any]))
                }
                
                //next create the sections

                let groups = Dictionary(grouping: self.friends!) { (friend) in
                    return String(friend.username.prefix(1))
                }
                
                self.sections = groups.map { args in
                    return UserSection(char: args.0, users: args.1)
                }.sorted()
                
                
                DispatchQueue.main.async {
                    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellReuseIdentifier)
                    self.tableView.delegate = self
                    self.tableView.dataSource = self

                    self.tableView.reloadData()
                }

            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Table View override methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.sections[section]

        return section.char.uppercased()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.sections[section]
        return section.users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 75;//Choose your custom row height
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:UserTableViewCell = (self.tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserTableViewCell?)!
        
        let section = self.sections[indexPath.section]
        let friend = section.users[indexPath.row]
        
        cell.username.text = friend.username
        

        let pictureURL = BaseParams.url == "http://localhost:3000" ? URL(string: "http://localhost:3000/\(friend.avatar)") : URL(string: friend.avatar)

        var catPicture: UIImage

        if let pictureData = NSData(contentsOf: pictureURL! as URL) {
            catPicture = UIImage(data: pictureData as Data)!
            cell.avatar.layer.cornerRadius = 30
        }
        else {
            catPicture = UIImage(named: "user_icon")!
        }

        cell.avatar.layer.masksToBounds = true
        cell.avatar.image = catPicture

        return cell
    }
    
    // method to run when table view cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        if let user = self.user {
            vc.user = user
            
            let section = self.sections[indexPath.section]
            vc.friend = section.users[indexPath.row]
            vc.manager = self.manager
            vc.socket = self.socket
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        
        if parent == nil {
            // The view is being removed from the stack, so call your function here
            socket.disconnect()
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

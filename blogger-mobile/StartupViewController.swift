//
//  StartupViewController.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 5/26/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

import UIKit

class StartupViewController: UIViewController {

    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadingSpinner.startAnimating()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let token = BaseParams.keychain["token"] {
            BaseParams.fetchPostJson(token: token) { (json) in
                let success = json["success"] as! Bool
                if (success) {
                    let posts = Post.parseJson(json_posts: json["posts"] as! [Any])
                    let user = User(json: json)
                    user.token = token
                    
                    let vc = storyboard.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
                    
                    vc.posts = posts
                    vc.user = user
                    
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                else {
                    if let message = json["message"] {
                        print(message)
                    }
                    //something happened, probably an invalid token. redirect back to the login page and unset the token
                    BaseParams.keychain["token"] = nil
                    
                    let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                    
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                }
                
            }
        }
        else {
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            
            self.navigationController?.pushViewController(vc, animated: true)
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

}

//
//  StartupViewController.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 5/26/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

import UIKit

class StartupViewController: BaseController {

    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadingSpinner.startAnimating()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if let token = self.keychain["token"] {
            print("the token is \(token)")
            self.fetchPostJson(token: token) { (json) in
                let posts = Post.parseJson(json_posts: json["posts"] as! [Any])
                let user = User(json: json)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let vc = storyboard.instantiateViewController(withIdentifier: "VerticalViewController") as! VerticalViewController
                
                vc.posts = posts
                vc.user = user
                
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

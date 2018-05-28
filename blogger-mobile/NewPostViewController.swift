//
//  NewPostViewController.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 5/6/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

import UIKit

class NewPostViewController: BaseController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textView: UITextView!
    
    var user: User? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        activityIndicator.isHidden = true

        // Do any additional setup after loading the view.
    }

    @IBAction func newPostSubmit(_ sender: Any) {
        print("it worked! you submitted some text!")
        //now do a request with the token
        let url = "\(self.url)/api/create_post"
        
        let post = "<p>\(self.textView!.text!.replacingOccurrences(of: "\n", with: "<br>"))</p>"
        
        let postParams = [
            "token": self.user!.token,
            "post": post
        ]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        Request.post(url, postParams) { (jsonData) in
            let success = jsonData["success"] as! Bool

            print(success ? "success!" : "failed to create post")
            
            //go back to posts controller ("VerticalViewController")
            
            let vc = storyboard.instantiateViewController(withIdentifier: "VerticalViewController") as! VerticalViewController
            
            vc.user = self.user!
            
            self.fetchPostJson(token: self.user!.token) { (json) in
                vc.posts = Post.parseJson(json_posts: json["posts"] as! [Any])
                
                DispatchQueue.main.sync {
                    self.activityIndicator.stopAnimating()
                    self.navigationController?.pushViewController(vc, animated: true)
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

}

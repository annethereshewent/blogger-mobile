//
//  NewPostViewController.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 5/6/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

import UIKit

class NewPostViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    var user: User? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        activityIndicator.isHidden = true
        textView.layer.cornerRadius = 15
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.black.cgColor
        textView.addDoneOnKeyboardWithTarget(self, action: #selector(self.doneAction(_:)), shouldShowPlaceholder: true)
        
    }
    
    @objc func doneAction(_ sender: UITextView) {
        self.view.endEditing(true)
        submitButton.sendActions(for: .touchUpInside)
        
    }

    @IBAction func newPostSubmit(_ sender: Any) {
        //now do a request with the token
        let url = "\(BaseParams.url)/api/create_post"
        
        let post = "<p>\(self.textView!.text!.replacingOccurrences(of: "\n", with: "<br>"))</p>"
        
        if let user = self.user {
            let postParams = [
                "post": post
            ]
            
            let headers = [
                "Authorization": user.token
            ]
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            Request.post(url, postParams, headers) { (jsonData) in
                let success = jsonData["success"] as! Bool
                
                print(success ? "success!" : "failed to create post")
                
                //go back to posts controller ("VerticalViewController")
                
                let vc = storyboard.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
                
                vc.user = self.user!
                
                BaseParams.fetchPostJson(token: user.token) { (json) in
                    let success = json["success"] as! Bool
                    if (success) {
                        vc.posts = Post.parseJson(json_posts: json["posts"] as! [Any])
                        
                        DispatchQueue.main.sync {
                            self.activityIndicator.stopAnimating()
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                    else {
                        if let message = json["message"] as! String? {
                            print(message)
                            if (message == "invalid_token") {
                                BaseParams.keychain["token"] = nil
                                
                                let vc = storyboard.instantiateViewController(withIdentifier: "ViewController")
                                
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
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

}

//
//  ViewController.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 8/30/17.
//  Copyright © 2017 blogger_mobile. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    //MARK: Properties
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardWhenTappedAround()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    
        passwordField.delegate = self
        activityIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        submitButton.sendActions(for: .touchUpInside)
        
        return true
    }
    
    
    @IBAction func userRegister(_ sender: Any) {
        //display the modal
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterController")
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func userSubmit(_ sender: Any) {
        //here's where we do an API request to get user data
        let url = "\(BaseParams.url)/api/login"
        
        let postParams = [
            "username": userField.text!,
            "password": passwordField.text!
        ]
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        Request.post(url, postParams) { (jsonData) in
            let success = jsonData["success"] as! Bool
            if (success) {
                DispatchQueue.main.async {
                    self.errorLabel.text = ""
                }
                
                print(jsonData)
                
                
                
                let user = User(json: jsonData)
                
                BaseParams.keychain["token"] = user.token
                
                let posts = Post.parseJson(json_posts: jsonData["posts"] as! [Any])
                
                //now switch the screens to another screen
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let vc = storyboard.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
                
                vc.posts = posts
                vc.user = user
                
                
                print("test?")
                DispatchQueue.main.async {
                    self.activityIndicator.isHidden = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Wrong username or password."
                    self.activityIndicator.isHidden = true
                }
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//
//  RegisterController.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 5/27/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

import UIKit

class RegisterController: BaseController, UITextFieldDelegate {

    @IBOutlet weak var blogTitleField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordField2: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func userCancel(_ sender: Any) {
        print("you clicked on the cancel button!")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewController")
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func userRegister(_ sender: Any) {
        //first validate the fields, make sure that required fields are filled in and passwords match
        if (emailField.text == "" || usernameField.text == "" || passwordField.text == "" || passwordField2.text == "") {
            errorLabel.text = "Please fill in the required fields."
        }
        else if (passwordField.text != passwordField2.text) {
            errorLabel.text = "Password fields must match."
        }
        else {
            errorLabel.text = ""
            
            //register the user
            let postParams = [
                "blog_title": blogTitleField.text!,
                "displayname": usernameField.text!,
                "email": emailField.text!,
                "password": passwordField.text!
            ]
            
            let url = "\(self.url)/api/register"
            
            Request.post(url, postParams) { (json) in
                print(json)
                let success = json["success"] as! Bool
                if (success) {
                    print("registered user successfully!")
                    let user = User(json: json)
                    let posts: [Post] = []
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "VerticalViewController") as! VerticalViewController
                    
                    vc.posts = posts
                    vc.user = user
                    
                    DispatchQueue.main.async {
                        print("attempting to use the navigation controller....")
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                else {
                    if let message = json["message"] {
                        print(message)
                    }
                    
                    DispatchQueue.main.async {
                        self.errorLabel.text = "Unable to register user."
                    }
                    print("could not register user.")
                }
            }
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.isHidden = true
        self.hideKeyboardWhenTappedAround()
        self.navigationController?.isNavigationBarHidden = false

        passwordField2.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        registerButton.sendActions(for: .touchUpInside)
        return true
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

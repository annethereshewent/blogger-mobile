//
//  ViewController.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 8/30/17.
//  Copyright © 2017 blogger_mobile. All rights reserved.
//

import UIKit

class ViewController: BaseController, UITextFieldDelegate {
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        submitButton.sendActions(for: .touchUpInside)
        
        return true
    }
    
    @IBAction func userSubmit(_ sender: Any) {
        //here's where we do an API request to get user data
        let url = URL(string: "\(self.url)/api/login")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let postParams = "username=" + userField.text! + "&password=" + passwordField.text!
        
        request.httpBody = postParams.data(using: .utf8)
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(error!)")
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response!)")
            }

            if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] {
                let success = jsonData["success"] as! Bool
                if (success) {
                    DispatchQueue.main.async {
                        self.errorLabel.text = ""
                    }
                    
                    print(jsonData)
                    
                    
                    
                    let user = User(json: jsonData)
                    
                    self.keychain["token"] = user.token
                    
                    let posts = Post.parseJson(json_posts: jsonData["posts"] as! [Any])
                    
                    //now switch the screens to another screen
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    let vc = storyboard.instantiateViewController(withIdentifier: "VerticalViewController") as! VerticalViewController
                    
                    vc.posts = posts
                    vc.user = user
                    
                    
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
            else {
                print("An error has occurred.")
            }
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

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
    
    var user: User? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true

        // Do any additional setup after loading the view.
    }

    @IBAction func newPostSubmit(_ sender: Any) {
        print("it worked! you submitted some text!")
        //now do a request with the token
        let url = URL(string: "http://localhost:3000/api/create_post")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let post = "<p>\(self.textView!.text!.replacingOccurrences(of: "\n", with: "<br>"))</p>"
        
        let postParams = "token=\(self.user!.token)&post=\(post)&user_id=\(self.user!.user_id)"
        
        request.httpBody = postParams.data(using: .utf8)
        
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(error!)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response!)")
            }
            
            var jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            if (jsonData != nil) {
                let success = jsonData!!["success"] as! Bool
                if (success) {
                    print("success!")
                    
                    //go back to posts controller ("VerticailViewController")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    let vc = storyboard.instantiateViewController(withIdentifier: "VerticalViewController") as! VerticalViewController
                    
                    vc.user = self.user!
                    
                    let url = URL(string: "http://localhost:3000/api/fetch_posts?token=\(self.user!.token)&user_id=\(self.user!.user_id)")!
                    var request = URLRequest(url: url)
                    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    request.httpMethod = "GET"
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {
                            print("error=\(error!)")
                            return
                        }
                        
                        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                            print("statusCode should be 200, but is \(httpStatus.statusCode)")
                            print("response = \(response!)")
                        }
                        
                        var jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        if (jsonData != nil) {
                            let success = jsonData!!["success"] as! Bool
                            
                            if (success) {
                                let _posts = jsonData!!["posts"] as? [Any]
                                
                                var posts: [Post] = []
                                for post in _posts! {
                                    posts.append(Post(post: post as! [String : Any]))
                                }
                                
                                
                                print("fetched posts was a success!")
                                vc.posts = posts
                                
                                
                                DispatchQueue.main.sync {
                                    self.activityIndicator.stopAnimating()
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                                
                            }
                            else {
                                print("an error has occurred")
                            }
                        }
                        else {
                            print("an error has occurred")
                        }
                    }
                    task.resume()
                }
                else {
                    print("json data is nil for some reason :/")
                }
            }
        }
        task.resume()
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

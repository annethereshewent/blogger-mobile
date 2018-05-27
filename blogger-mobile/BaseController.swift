//
//  BaseController.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 5/26/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

import UIKit
import KeychainAccess

class BaseController: UIViewController {
    let url: String = "https://blogger-243.herokuapp.com"
    let keychain = Keychain(server: "https://github.com", protocolType: .https)
    
    
    func fetchPostJson(token: String, completionBlock: @escaping ([String: Any]) -> Void) -> Void {
        let url = URL(string: "\(self.url)/api/fetch_posts?token=\(token)")!
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
            
            if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] {
                let success = jsonData["success"] as! Bool
                
                if (success) {
                    completionBlock(jsonData)
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

}

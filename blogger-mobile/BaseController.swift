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
    //let url: String = "http://localhost:3000"
    let url: String = "https://blogger-243.herokuapp.com"
    let keychain = Keychain(server: "https://github.com", protocolType: .https)
    
    
    func fetchPostJson(token: String, callback: @escaping ([String: Any]) -> Void) -> Void {
        let url = "\(self.url)/api/fetch_posts?token=\(token)"
        Request.get(url) { (json) in
            let success = json["success"] as! Bool
            
            if (success) {
                callback(json)
            }
            else {
                print("an error has occurred")
            }
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .unicode) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

//
//  BaseParams.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 7/26/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

import KeychainAccess

class BaseParams {
    static let url: String = "http://localhost:3000"
    //static let url: String = "https://blogger-243.herokuapp.com"
    static let keychain = Keychain(server: "https://github.com", protocolType: .https)
    
    static let chat_url = "http://localhost:3001"
    //static let chat_url = "https://blogger243chat.herokuapp.com"
    
    static func fetchPostJson(token: String, callback: @escaping ([String: Any]) -> Void) -> Void {
        let url = "\(self.url)/api/fetch_posts"
        Request.get(url, ["Authorization": token]) { (json) in
            callback(json)
        }
    }
}

//
//  User.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 5/6/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//



class User {
    var user_id: Int
    var username: String
    var token: String
    var avatar: String
    
    init(json: [String: Any]) {
        self.user_id = json["user_id"] as? Int ?? -1
        self.username = json["username"] as? String ?? ""
        self.token = json["token"] as? String ?? ""
        self.avatar = json["avatar"] as? String ?? ""
    }
}

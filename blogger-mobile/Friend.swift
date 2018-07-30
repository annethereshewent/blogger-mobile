//
//  Friend.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 7/22/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

class Friend {
    var username: String
    var user_id: Int
    var avatar: String
    
    init(json: [String: Any] ) {
        username = json["username"] as! String
        user_id = json["user_id"] as! Int
        avatar = json["avatar"] as! String
    }
}

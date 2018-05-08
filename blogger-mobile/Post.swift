//
//  Post.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 5/5/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

class Post {
    var post: String
    var created_at: String
    var updated_at: String
    var edited: Bool
    var num_comments: Int
    var username: String
    var avatar: String
    var images: [String]
    
    init(post: [String: Any]) {
        self.post = post["post"] as? String ?? ""
        self.created_at = post["created_at"] as? String ?? ""
        self.edited = post["edited"] as? Bool ?? false
        self.num_comments = post["num_comments"] as? Int ?? 0
        self.updated_at = post["updated_at"] as? String ?? ""
        self.username = post["username"] as? String ?? ""
        self.avatar = post["avatar"] as? String ?? ""
        self.images = post["images"] as? [String] ?? []
    }
}

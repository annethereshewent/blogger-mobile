//
//  Comment.swift
//  blogger-mobile
//
//  Created by Anne Castrillon on 7/29/18.
//  Copyright © 2018 blogger_mobile. All rights reserved.
//

    class Comment {
        var comment: String
        var id: Int;
        var parent: Int;
        var username: String;
        var avatar: String;
        var indentLevel: Int;
        
        
        init(_ comment: [String: Any]) {
            self.comment = comment["comment"] as? String ?? ""
            self.id = comment["id"] as? Int ?? -1
            self.parent = comment["parent"] as? Int ?? -1
            self.username = comment["username"] as? String ?? ""
            self.avatar = comment["avatar"] as? String ?? ""
            self.indentLevel = comment["indentLevel"] as? Int ?? 0
        }
    }

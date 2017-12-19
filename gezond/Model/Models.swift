//
//  Models.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 19-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import Foundation

class GUser {
    let userID: String
    let name: String
    let imageURL: URL
    var isInvited: Bool = false
    var isFriend: Bool = false
    
    init?(userDictionary: [String: Any]?) {
        guard let name = userDictionary?["name"] as? String,
            let uid = userDictionary?["userID"] as? String,
            let imageURLString = userDictionary?["imageURL"] as? String,
            let imageURL = URL(string: imageURLString) else { return nil }
        self.userID = uid
        self.name = name
        self.imageURL = imageURL
    }
}

class GPost {
    let imageURL: URL
    let postText: String
    let timeStamp: Double
    let userID: String
    
    init?(post: [String: Any]?) {
        guard let aPost = post,
            let imageURLString = aPost["imageURL"] as? String,
            let url = URL(string: imageURLString ),
            let text = aPost["postText"] as? String,
            let timeStamp = aPost["timestamp"] as? Double,
            let userID = aPost["userID"] as? String else { return nil }
        self.imageURL = url
        self.postText = text
        self.timeStamp = timeStamp
        self.userID = userID
    }
}

class GUserLight {
    var userID: String
    var name: String
    var imageURL: URL
    
    init?(userDictionary: [String: String]?) {
        guard let uid = userDictionary?["userID"],
            let name = userDictionary?["name"],
            let urlString = userDictionary?["imageURL"],
            let url = URL(string: urlString) else { return nil}
        self.userID = uid
        self.name = name
        self.imageURL = url
    }
}

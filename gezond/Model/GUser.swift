//
//  Friend.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 11-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import Foundation
import Firebase

class GUser {
    let uid: String
    let name: String
    let imageURL: URL
    var isInvited: Bool = false
    var isFriend: Bool = false
    //let tagline: String
    
    init?(userDictionary: [String: Any]?) {
        guard let name = userDictionary?["name"] as? String,
            let uid = userDictionary?["uid"] as? String,
            let imageURLString = userDictionary?["imageURL"] as? String,
            let imageURL = URL(string: imageURLString) else { return nil }
        self.uid = uid
        self.name = name
        self.imageURL = imageURL
    }
}

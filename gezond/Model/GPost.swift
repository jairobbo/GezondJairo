//
//  Post.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 08-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import Foundation

class GPost {
    let imageURL: URL
    let postText: String
    let timeStamp: Double
    
    init?(post: [String: Any]?) {
        print(post)
        guard let post = post,
            let imageURLString = post["imageURL"] as? String,
            let url = URL(string: imageURLString ),
            let text = post["postText"] as? String,
            let timeStamp = post["timestamp"] as? Double else { return nil }
        self.imageURL = url
        self.postText = text
        self.timeStamp = timeStamp
    }
}

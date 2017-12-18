//
//  Post.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 08-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import Foundation

class Post {
    let imageURL: URL
    let postText: String
    
//    init?(imageURLString: String, text: String) {
//        guard let url = URL(string: imageURLString) else { return nil }
//        self.imageURL = url
//        self.postText = text
//    }
    
    init?(post: [String: Any]?) {
        guard let post = post,
            let imageURLString = post["imageURL"] as? String,
            let url = URL(string: imageURLString ),
            let text = post["postText"] as? String else { return nil }
        self.imageURL = url
        self.postText = text
    }
}

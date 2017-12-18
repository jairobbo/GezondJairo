//
//  GezondPost.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 14-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import Foundation
import Firebase

class GezondPost {
    
    class func get(uid: String, completion: @escaping ([Post])->Void ) {
        Database.database().reference().child("users").child(uid).child("posts").observe(.value) { (snapshot) in
            var postsWithOptionals: [[String: Any]?] = []
            let enumerator = snapshot.children
            
            while let child = enumerator.nextObject() as? DataSnapshot {
                let post = child.value as? [String: Any]
                postsWithOptionals.append(post)
            }
            let posts = postsWithOptionals.flatMap({ (optPost) -> Post? in
                Post.init(post: optPost)
            })
            completion(posts)
        }
    }
    
    class func create(image: UIImage, text: String, uid: String, completion: @escaping (Error?)->Void) {
        let postRef = Database.database().reference().child("users").child(uid).child("posts").childByAutoId()
        let storageRef = Storage.storage().reference()
        print("post.key = \(postRef.key)")
        
        guard let data = UIImageJPEGRepresentation(image, 0.8) else { return }
        storageRef.child("postImages/\(postRef.key).jpg").putData(data, metadata: nil, completion: { (metadata, error) in
            if error == nil {
                guard let url = metadata?.downloadURL() else { return }
                postRef.child("imageURL").setValue(url.absoluteString)
                postRef.child("postText").setValue(text)
                postRef.child("user").setValue(uid)
                postRef.child("timestamp").setValue(Date.timeIntervalSinceReferenceDate)
                completion(nil)
            } else {
                completion(error)
            }
        })
    }
}

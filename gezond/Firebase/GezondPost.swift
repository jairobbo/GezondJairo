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
    
    class func observeUserPosts(userID: String, eventType: DataEventType, completion: @escaping (GPost?)->Void ) {
        let postsRef = Database.database().reference().child("users").child(userID).child("posts")
        postsRef.observeSingleEvent(of: .value) { (snaphot) in
            if snaphot.childrenCount == 0 {
                completion(nil)
            }
        }
        postsRef.observe(eventType) { (snapshot) in
            let postsDictionary = snapshot.value as? [String: Any]
            let post = GPost(post: postsDictionary)
            completion(post)
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
                let postObject: [String: Any] = ["imageURL": url.absoluteString, "postText": text, "timestamp": Date.timeIntervalSinceReferenceDate]
                postRef.setValue(postObject)
                completion(nil)
            } else {
                completion(error)
            }
        })
    }
}

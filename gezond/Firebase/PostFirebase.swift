//
//  GezondPost.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 14-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import Foundation
import Firebase

class PostFirebase {
    
    static let usersRef = Database.database().reference().child("users")
    
    class func observeTimelinePosts(eventType: DataEventType, completion: @escaping (GPost?)->Void) {
        guard let user = Auth.auth().currentUser else { completion(nil); return }
        usersRef.child(user.uid).child("friends").observe(eventType, with: { (snapshot) in
            DispatchQueue.main.async {
                guard let friendDictionary = snapshot.value as? [String: String],
                    let userID = friendDictionary["userID"] else { completion(nil); return }
                let postsRef = usersRef.child(userID).child("posts")
                postsRef.observe(eventType, with: { (snapshot) in
                    DispatchQueue.main.async {
                        let optionalPostDictionary = snapshot.value as? [String: Any]
                        let post = GPost(post: optionalPostDictionary)
                        completion(post)
                    }
                })
            }
        })
    }
    
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
    
    class func create(image: UIImage, text: String, userID: String, completion: @escaping (Error?)->Void) {
        let postRef = Database.database().reference().child("users").child(userID).child("posts").childByAutoId()
        let storageRef = Storage.storage().reference()
        print("post.key = \(postRef.key)")
        
        guard let data = UIImageJPEGRepresentation(image, 0.8) else { return }
        storageRef.child("postImages/\(postRef.key).jpg").putData(data, metadata: nil, completion: { (metadata, error) in
            if error == nil {
                guard let url = metadata?.downloadURL() else { return }
                let postObject: [String: Any] = ["imageURL": url.absoluteString, "postText": text, "timestamp": Date.timeIntervalSinceReferenceDate, "userID": userID]
                postRef.setValue(postObject)
                completion(nil)
            } else {
                completion(error)
            }
        })
    }
}

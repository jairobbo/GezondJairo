//
//  CommentFirebase.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 30-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import Foundation
import Firebase

class CommentFirebase {
    
    static let usersRef = Database.database().reference().child("users")
    
    class func observeComments(userID: String, imageURL: String, eventType: DataEventType, completion: @escaping (GComment?) -> Void) {
        usersRef.child(userID).child("posts").queryOrdered(byChild: "imageURL").queryEqual(toValue: imageURL).observeSingleEvent(of: .value) { (snapshot) in
            if let snapshotDictionary = snapshot.value as? [String: Any],
                let key = snapshotDictionary.keys.first {
                usersRef.child(userID).child("posts").child(key).child("comments").observe(eventType) { (snapshot) in
                    let commentDictionary = snapshot.value as? [String: Any]
                    let comment = GComment(commentDictionary: commentDictionary)
                    completion(comment)
                }
            }
        }
    }
    
    class func addComment(post: GPost, user: User, text: String) {
        let commentDictionary: [String: Any] = [
            "timestamp": Date.timeIntervalSinceReferenceDate,
            "userID": user.uid,
            "comment": text,
            "imageURL": user.photoURL?.absoluteString ?? ""
        ]
        usersRef.child(post.userID).child("posts").queryOrdered(byChild: "imageURL").queryStarting(atValue: post.imageURL.absoluteString).queryLimited(toFirst: 1).observeSingleEvent(of: .value) { (snapshot) in
            if let snapshotDictionary = snapshot.value as? [String: Any],
                let key = snapshotDictionary.keys.first {
                let newCommentRef = usersRef.child(post.userID).child("posts").child(key).child("comments").childByAutoId()
                newCommentRef.setValue(commentDictionary)
            }
        }
    }
}

 //
//  User.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 14-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import Firebase

class UserFirebase {
    
    static let usersRef = Database.database().reference().child("users")
    static let currentUser = Auth.auth().currentUser
    
    class func login(completion: @escaping (Bool) -> Void  ) {
        guard FBSDKAccessToken.current() != nil else { completion(false); return }
        let token = FBSDKAccessToken.current().tokenString
        let credential = FacebookAuthProvider.credential(withAccessToken: token!)
        Auth.auth().signIn(with: credential, completion: { user, error in
            guard error == nil,
                let user = user else { completion(false); return }
            usersRef.child(user.uid).child("name").setValue(user.displayName)
        usersRef.child(user.uid).child("imageURL").setValue(user.photoURL?.absoluteString)
            usersRef.child(user.uid).child("userID").setValue(user.uid)
            completion(true)
        })
    }
    
    class func searchUsers(searchText: String?, completion: @escaping ([GUser])->Void ) {
        guard let text = searchText,
            let user = currentUser else { completion([]); return }
        let foundUsersRef = usersRef.queryOrdered(byChild: "name").queryStarting(atValue: text).queryEnding(atValue: "\(text)\\uf8ff")
        foundUsersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let enumerator = snapshot.children
            var optionalUserDictionaries = [[String: Any]?]()
            while let child = enumerator.nextObject() as? DataSnapshot {
                let friendDictionary = child.value as? [String: Any]
                optionalUserDictionaries.append(friendDictionary)
            }
            let friends: [GUser] = optionalUserDictionaries.flatMap({ (optionalFriend) -> GUser? in
                let friend = GUser.init(userDictionary: optionalFriend)
                if let inviteUIDs = optionalFriend?["invites"] as? [String: Any] {
                    if inviteUIDs.keys.contains(user.uid) {
                        friend?.isInvited = true
                    }
                }
                if let friendsUIDs = optionalFriend?["friends"] as? [String: Any] {
                    if friendsUIDs.keys.contains(user.uid) {
                        friend?.isFriend = true
                    }
                }
                return friend
            })
            completion(friends)
        })
    }
    
    class func invite(userID: String, completion: @escaping (Bool)->Void) {
        guard let user = currentUser else { completion(false); return }
        let invitesRef = usersRef.child(userID).child("invites")
        let userObject = ["userID": user.uid, "name": user.displayName, "imageURL": user.photoURL?.absoluteString]
        invitesRef.child(user.uid).setValue(userObject)
        completion(true)
    }
    
    class func uninvite(userID: String, completion: @escaping (Bool)->Void) {
        guard let user = currentUser else { completion(false); return}
        let friendRef = usersRef.child(userID).child("invites")
        friendRef.queryEqual(toValue: user.uid).ref.removeValue()
        completion(true)
    }
    
    class func get(userID: String, completion: @escaping (GUser?)->Void) {
        usersRef.child(userID).observeSingleEvent(of: .value) { (snapshot) in
            let optionalUser = snapshot.value as? [String: Any]
            let user = GUser(userDictionary: optionalUser)
            completion(user)
        }
    }
    
    class func observeInvitesAndFriends(directory: String, eventType: DataEventType, completion: @escaping (GUserLight?)->Void) {
        guard let user = currentUser else { completion(nil); return }
        usersRef.child(user.uid).child(directory).observe(eventType) { (snapshot) in
            DispatchQueue.main.async {
                guard let addedFriendDictionary = snapshot.value as? [String: String] else { completion(nil); return }
                let addedFriend = GUserLight(userDictionary: addedFriendDictionary)
                completion(addedFriend)
            }
        }
    }
    
    class func acceptInvite(inviteUser: GUserLight, completion: @escaping (Bool)->Void) {
        guard let user = currentUser else { completion(false); return }
        usersRef.child(user.uid).child("invites").child(inviteUser.userID).ref.removeValue()
        let friendObject = ["userID": inviteUser.userID, "name": inviteUser.name, "imageURL": inviteUser.imageURL.absoluteString]
        usersRef.child(user.uid).child("friends").child(inviteUser.userID).setValue(friendObject)
        let yourObject = ["userID": user.uid, "name": user.displayName, "imageURL": user.photoURL?.absoluteString]
        usersRef.child(inviteUser.userID).child("friends").child(user.uid).setValue(yourObject)
        completion(true)
    }
    
    class func declineInvite(inviteUser: GUserLight, completion: @escaping (Bool)->Void) {
        guard let user = currentUser else { completion(false); return }
        usersRef.child(user.uid).child("invites").child(inviteUser.userID).ref.removeValue()
        completion(true)
    }
}

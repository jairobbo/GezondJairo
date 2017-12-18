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

class GezondUser {
    
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
            usersRef.child(user.uid).child("uid").setValue(user.uid)
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
                if let inviteUIDs = optionalFriend?["invites"] as? [String: String] {
                    if inviteUIDs.values.contains(user.uid) {
                        friend?.isInvited = true
                    }
                }
                if let friendsUIDs = optionalFriend?["friends"] as? [String: String] {
                    if friendsUIDs.values.contains(user.uid) {
                        friend?.isFriend = true
                    }
                }
                return friend
            })
            completion(friends)
        })
    }
    
    class func invite(uid: String, completion: @escaping (Bool)->Void) {
        guard let user = currentUser else { completion(false); return }
        let friendRef = usersRef.child(uid).child("invites")
        friendRef.child(uid).child("uid").setValue(user.uid)
        friendRef.child(uid).child("name").setValue(user.displayName)
        friendRef.child(uid).child("imageURL").setValue(user.photoURL)
        completion(true)
    }
    
    class func uninvite(uid: String, completion: @escaping (Bool)->Void) {
        guard let user = currentUser else { completion(false); return}
        let friendRef = usersRef.child(uid).child("invites")
        friendRef.queryEqual(toValue: user.uid).ref.removeValue()
        completion(true)
    }
    
    class func getInvitesOrFriends(type: String, completion: @escaping ([GUserLight])->Void) {
        guard let user = currentUser else { completion([]); return }
        usersRef.child(user.uid).child(type).observeSingleEvent(of: .value){ (snapshot) in
            DispatchQueue.main.async {
                var optionalInvitesDictionary: [[String: String]?] = []
                let enumerator = snapshot.children
                while let invite = enumerator.nextObject() as? DataSnapshot {
                    let inviteDictionary = invite.value as? [String: String]
                    optionalInvitesDictionary.append(inviteDictionary)
                }
                let invites = optionalInvitesDictionary.flatMap({ (optionalInvite) -> GUserLight? in
                    GUserLight.init(userDictionary: optionalInvite)
                })
                completion(invites)
            }
        }
    }
    
    class func get(uid: String, completion: @escaping (GUser?)->Void) {
        usersRef.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            let optionalFriend = snapshot.value as? [String: Any]
            let friend = GUser(userDictionary: optionalFriend)
            completion(friend)
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
        usersRef.child(user.uid).child("invites").child(inviteUser.uid).ref.removeValue()
        let friendObject = ["uid": inviteUser.uid, "name": inviteUser.name, "imageURL": inviteUser.imageURL.absoluteString]
        usersRef.child(user.uid).child("friends").child(inviteUser.uid).setValue(friendObject)
        let yourObject = ["uid": user.uid, "name": user.displayName, "imageURL": user.photoURL?.absoluteString]
        usersRef.child(inviteUser.uid).child("friends").child(user.uid).setValue(yourObject)
        completion(true)
    }
    
    class func declineInvite(inviteUser: GUserLight, completion: @escaping (Bool)->Void) {
        guard let user = currentUser else { completion(false); return }
        usersRef.child(user.uid).child("invites").child(inviteUser.uid).ref.removeValue()
        completion(true)
    }
}

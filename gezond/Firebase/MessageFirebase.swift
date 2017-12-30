//
//  MessageFirebase.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 28-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import Foundation
import Firebase

class MessageFireBase {
    
    static var usersRef = Database.database().reference().child("users")
    
    class func addFCMToken(userID: String, token: String) {
        usersRef.child(userID).child("FCMToken").setValue(token)
    }
    
    
}

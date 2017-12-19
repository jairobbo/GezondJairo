//
//  ViewController.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 05-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class LoginVC: UIViewController {

    let loginButton = FBSDKLoginButton()
    var user: User!
    var usersRef = DatabaseReference()
    var loginCallback: ((User?, Error?) -> ())!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.delegate = self
        loginButton.loginBehavior = FBSDKLoginBehavior.native
        loginButton.readPermissions = ["public_profile", "email"]
        loginButton.center = view.center
        view.addSubview(loginButton)
        
        UserFirebase.login { (status) in
            if status {
                self.performSegue(withIdentifier: "enterApp", sender: self)
            }
        }
    }
}

extension LoginVC: FBSDKLoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logout")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            let loginFailAlert = UIAlertController(title: "Oeps!", message: "Er is iets mis gegaan bij het inloggen", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            loginFailAlert.addAction(okAction)
            present(loginFailAlert, animated: true, completion: nil)
        } else {
            UserFirebase.login { (status) in
                if status {
                    self.performSegue(withIdentifier: "enterApp", sender: self)
                }
            }
        }
    }
}


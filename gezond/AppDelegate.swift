//
//  AppDelegate.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 05-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import Fabric
import Crashlytics
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        Fabric.with([Crashlytics.self])
        
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.sound, .badge, .alert]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) {
            (authorized, error) in
        }
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loadingVC = storyboard.instantiateViewController(withIdentifier: "LoadingVC")
        window?.rootViewController = loadingVC
        if FBSDKAccessToken.current() != nil {
            UserFirebase.login(completion: { (status) in
                if status == true {
                    let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC")
                    self.window?.rootViewController = homeVC
                } else {
                    let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
                    self.window?.rootViewController = loginVC
                }
            })
        } else {
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
            self.window?.rootViewController = loginVC
        }
        
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        guard let user = Auth.auth().currentUser else { return }
        MessageFireBase.addFCMToken(userID: user.uid, token: fcmToken)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return handled
    }

}


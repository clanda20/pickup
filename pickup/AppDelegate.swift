//
//  AppDelegate.swift
//  pickup
//
//  Created by christian landa on 5/20/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
//import UserNotifications


import FirebaseInstanceID
import FirebaseMessaging

//import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
 /*   override init() {
        super.init()
    
        FIRDatabase.database().persistenceEnabled = true
        
        
       
    }  */

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
    FIRApp.configure()
        
    FIRDatabase.database().persistenceEnabled = true
        
       
        let notificationTypes : UIUserNotificationType = [UIUserNotificationType.Alert, .Badge, .Sound]
        let notificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(notificationSettings)
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
       
        return true
       
     
       
    }
    
    
    // [START receive_message]
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                     fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
    
            print(" ##### ", userInfo)
            // create a corresponding local notification
            
            if (userInfo["subject"] != nil && userInfo["to_user_ids"] != nil){
                
                let notification = UILocalNotification()
                notification.alertBody = userInfo["subject"] as? String // text that will be displayed in the notification
                notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
                notification.fireDate = NSDate.init() // todo item due date (when notification will be fired). immediately here
                notification.soundName = UILocalNotificationDefaultSoundName // play default sound
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
        }
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
     //   print("Message ID: \(userInfo["gcm.message_id"])")
        
        // Print full message.
       // print("%@", userInfo)
   // }
    // [END receive_message]
    
    
    
    // [START refresh_token]
    func tokenRefreshNotification(notification: NSNotification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    // [START connect_to_fcm]
    func connectToFcm() {
        FIRMessaging.messaging().connectWithCompletion { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    // [END connect_to_fcm]
    
    func applicationDidEnterBackground(application: UIApplication) {
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

   

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
         connectToFcm() //added sep 
    
    }

    func applicationWillTerminate(application: UIApplication) {
        
    }
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }  

}






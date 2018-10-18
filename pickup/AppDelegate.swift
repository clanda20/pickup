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
import UserNotifications


import FirebaseInstanceID
import FirebaseMessaging

//import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    override init() {
        super.init()
        
        FIRApp.configure()
    
        FIRDatabase.database().persistenceEnabled = true
        
        
       
    }

    func application( application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // [START register_for_notifications] nov 9
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications] end nov 9
        
        
    FIRApp.configure()
        
    FIRDatabase.database().persistenceEnabled = true
        
        
        // Add observer for InstanceID token refresh callback. nov 9
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .firInstanceIDTokenRefresh,
                                               object: nil)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true  // nov 9
        
       
//        let notificationTypes : UIUserNotificationType = [UIUserNotificationType.alert, .badge, .sound]
//        let notificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
//        application.registerForRemoteNotifications()
//        application.registerUserNotificationSettings(notificationSettings)
//        
//        UIApplication.shared.applicationIconBadgeNumber = 0
//       
//        return true
       
     
       
    }
    
    
    // [START receive_message]
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                     fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        
        //  Nov 8 If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
      // print("Message ID: \(userInfo["gcm.message_id"]! as! [Any] )")
        
        // Print full message.
        print("%@", userInfo)
    }
    // [END receive_message]  Nov 8
        
//    
//            print(" ##### ", userInfo)
//            // create a corresponding local notification
//        
//            if (userInfo["subject"] != nil && userInfo["to_user_ids" ] != nil){
//                
//                let notification = UILocalNotification()
//                notification.alertBody = userInfo["subject"] as? String // text that will be displayed in the notification
//                notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
//                notification.fireDate = NSDate.init() as Date // todo item due date (when notification will be fired). immediately here
//                notification.soundName = UILocalNotificationDefaultSoundName // play default sound
//                UIApplication.shared.scheduleLocalNotification(notification)
//            }
//        }
    
 /*   func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
    }  */
    
    // [START refresh_token]
    @objc func tokenRefreshNotification(notification: NSNotification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    // [START connect_to_fcm]
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    // [END connect_to_fcm]
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        connectToFcm()
    }
    
    // [START disconnect_from_fcm]
    func applicationDidEnterBackground(_ application: UIApplication) {
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }
    // [END disconnect_from_fcm]


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

   

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }



    func applicationWillTerminate(_ application: UIApplication) {
        
    }
  //  func application(application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: Any) -> Bool {
  //      return FBSDKApplicationDelegate.sharedInstance().application(application, open: url as URL!, sourceApplication: sourceApplication, annotation: annotation)
   // }
  
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        if #available(iOS 9.0, *) {
//            let shouldOpen :Bool = FBSDKApplicationDelegate.sharedInstance().application(
//                app,
//                open: url as URL!,
//                sourceApplication: options["UIApplicationOpenURLOptionsSourceApplicationKey"] as! String,
//                annotation: nil)
//            
//       //     shouldOpen = shouldOpen ? shouldOpen : facebookLogin.sharedInstance().handleURL(url,sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String?,
//        //                                                                                annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
////            
//            return shouldOpen
//        } else {
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                     
                                                                     open: url, sourceApplication: sourceApplication, annotation: annotation)
//        }
//        return true
    }
    

}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]! )")
        
        // Print full message.
        print("%@", userInfo)
    }
}

extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("%@", remoteMessage.appData)
    }
}






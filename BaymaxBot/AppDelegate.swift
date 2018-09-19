//
//  AppDelegate.swift
//  BaymaxBot
//
//  Created by 石島樹 on 2018/04/28.
//  Copyright © 2018年 石島樹. All rights reserved.
//

import UIKit
import Firebase
import ApiAI
import UserNotifications
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var center: UNUserNotificationCenter?
    let gcmMessageIDKey = "gcm.message_id"
    let topicName = "Baymax"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Navigationbar設定
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: ViewController())
        window?.makeKeyAndVisible()
        
        // Firebase設定
        FirebaseApp.configure()
        // Push通知設定（FCM）
        self.center = UNUserNotificationCenter.current()
        guard let center = self.center else {
            return false
        }
        center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
            if error != nil {
                return
            }
            if granted {
                print("通知許可")
                center.delegate = self
                Messaging.messaging().delegate = self
                application.registerForRemoteNotifications()
            } else {
                print("通知拒否")
            }
        })
        // ApiAI設定
        let configuration: AIConfiguration = AIDefaultConfiguration()
        configuration.clientAccessToken = KeyManager().getValue(key: "dialogflowToken") as? String 
        let apiai = ApiAI.shared()
        apiai?.configuration = configuration
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // トピック購読解除
        Messaging.messaging().unsubscribe(fromTopic: topicName)
    }
    
    // バックグラウンド状態で通知を受信した際、通知をタップした時に呼ばれる
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
    }
    
    // バックグラウンド状態で通知を受信した際、通知をタップした時に呼ばれる
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // ローカル通知
    func sendNotification(title: String, message: String) {
        guard let center = self.center else {
            return
        }
        let content = UNMutableNotificationContent()
        content.title = title;
        content.body = message;
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest.init(identifier: "TestNotification", content: content, trigger: trigger)
        center.add(request)
    }
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // フォアグラウンドで通知を受け取った時
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("userNotificationCenter : willPresent")
        // バッジを設定すると通知バナーが表示されない…
        completionHandler([.alert, .sound])
    }
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
        // トピック購読
        Messaging.messaging().subscribe(toTopic: topicName)
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
}


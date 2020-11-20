//
//  AppDelegate.swift
//  LifeTravel
//
//  Created by JiuZhiJiao on 4/11/20.
//  Copyright © 2020 JiuZhiJiao. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate  {
    
    var databaseController: DatabaseProtocol?
    let locationManager = CLLocationManager()
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // set core data
        databaseController = CoreDataController()
        // set navigation
        
        // firebase configuration
        FirebaseApp.configure()
        
        // geofence
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        UNUserNotificationCenter.current()
            .requestAuthorization(options: options) { success, error in
                if let error = error{
                    print(error)
                } else {
                    UNUserNotificationCenter.current().delegate = self
                }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func handleEvent(for region: CLRegion!) {
           let notificationContent = UNMutableNotificationContent()
           notificationContent.body = "You have a note near you."
           notificationContent.sound = UNNotificationSound.default
           notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
           let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
           let request = UNNotificationRequest(identifier: "Notify", content: notificationContent, trigger: trigger)
           UNUserNotificationCenter.current().add(request) { error in
               if let error = error {
                   print(error)
               }
           }
       }
       
       
       
       
       // MARK: - CCLocationManagerDelegate
       
       func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
         if region is CLCircularRegion {
           handleEvent(for: region)
         }
       }
       
       // MARK: - UNUserNotificationCenterDelegate

        
       func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)

        guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
            return
        }
            //var viewController = UIViewController()
            //viewController = storyBoard.instantiateViewController(withIdentifier: "mapviewBoard")// user tap notification
           


        
            let conversationVC = storyBoard.instantiateViewController(withIdentifier: "tabBar") as! TabBarViewController
        let navcontroller = rootViewController as? UINavigationController
        conversationVC.selectedViewController = conversationVC.viewControllers![1]
        navcontroller!.pushViewController(conversationVC, animated: true)
        

            //self.window?.rootViewController = viewController
            //self.window?.makeKeyAndVisible()

            completionHandler()
       }
    /*
        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            
            // retrieve the root view controller (which is a tab bar controller)
            guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
                return
            }
          
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            // instantiate the view controller we want to show from storyboard
            // root view controller is tab bar controller
            // the selected tab is a navigation controller
            // then we push the new view controller to it
            if  let conversationVC = storyboard.instantiateViewController(withIdentifier: "mapviewBoard") as? MapViewController,
                let tabBarController = rootViewController as? UITabBarController,
                let navController = tabBarController.selectedViewController as? UINavigationController {

                    // we can modify variable of the new view controller using notification data
                    // (eg: title of notification)
                    conversationVC.senderDisplayName = response.notification.request.content.title
                    // you can access custom data of the push notification by using userInfo property
                    // response.notification.request.content.userInfo
                    navController.pushViewController(conversationVC, animated: true)
            }
            
            // tell the app that we have finished processing the user’s action / response
            completionHandler()
        }*/

    

}


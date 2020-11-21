//
//  SceneDelegate.swift
//  LifeTravel
//
//  Created by JiuZhiJiao on 4/11/20.
//  Copyright © 2020 JiuZhiJiao. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
        (UIApplication.shared.delegate as? AppDelegate)?.databaseController?.cleanup()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
        (UIApplication.shared.delegate as? AppDelegate)?.databaseController?.cleanup()
    }


}


//
//  AppDelegate.swift
//  vkLibManage
//
//  Created by Andrii Tiischenko on 10/5/16.
//  Copyright © 2016 Andrii Tiischenko. All rights reserved.
//

import UIKit


//= "notificationProgress"
//let notificationProgress: String = "notificationProgress"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var backgroundSessionCompletionHandler : (() -> Void)?
    
    /*
     private func application(application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        let wasHandled:Bool = VKSdk.processOpen(url, fromApplication: sourceApplication)
        
        return wasHandled
    }
 */

    func application(_ app: UIApplication,
                              open url: URL,
                              options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        let wasHandled:Bool = VKSdk.processOpen(url, fromApplication: "com.vkLibManage")
        
        return wasHandled
    }

    /*
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool{
        return true
    }
 */
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let s = Player.sharedInstance
        s.addToQueue(TrackItem())
        Player.sharedInstance.clearQueue()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        DBManager.sharedInstance.saveContext()
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }

   

}


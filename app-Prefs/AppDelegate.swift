//
//  AppDelegate.swift
//  app-Prefs
//
//  Created by 成璐飞 on 2016/12/16.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        /**
         * remeve because issues#1 in Github
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.chengluffy.app-Prefs")
        let realmURL = container!.appendingPathComponent("defualt.realm")
        
        Realm.Configuration.defaultConfiguration.fileURL = realmURL
        let realm = try! Realm()
        
        if UserDefaults.standard.object(forKey: "isFirstOpen") == nil || UserDefaults.standard.object(forKey: "isFirstOpen") as! Bool == true  {
            
            
            
            UserDefaults.standard.set(false, forKey: "isFirstOpen")
            
            let settings = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Settings", ofType: ".plist")!) as? Dictionary<String, String>
            
            for node in (settings?.enumerated())! {
                let model = Setting()
                model.name = node.element.key
                model.action = node.element.value
                model.type = ActionType.system.rawValue
                model.isDeleted = false
                model.sortNum = NSNumber.init(value: node.offset)
                print(node.offset)
                try! realm.write {
                    realm.add(model)
                }
            }
            
            print("config when first open")
        }
         */
        
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.chengluffy.app-Prefs")
        let realmURL = container!.appendingPathComponent("defualt.realm")
        
        Realm.Configuration.defaultConfiguration.fileURL = realmURL
        let realm = try! Realm()
        
        if UserDefaults.standard.object(forKey: "isFirstOpen") == nil || UserDefaults.standard.object(forKey: "isFirstOpen") as! Bool == true  {
            
            
            
            UserDefaults.standard.set(false, forKey: "isFirstOpen")
            
            let settings = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Settings", ofType: ".plist")!) as? Dictionary<String, String>
            
            for node in (settings?.enumerated())! {
                let model = Setting()
                model.name = node.element.key
                model.action = node.element.value
                model.type = ActionType.custom.rawValue
                model.isDeleted = false
                model.sortNum = NSNumber.init(value: node.offset)
                print(node.offset)
                try! realm.write {
                    realm.add(model)
                }
            }
            
            let systemSettings = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "SystemSettings", ofType: ".plist")!) as? Dictionary<String, String>
            
            for node in (systemSettings?.enumerated())! {
                let model = Setting()
                model.name = node.element.key
                model.action = node.element.value
                model.type = ActionType.system.rawValue
                model.isDeleted = true
                model.sortNum = NSNumber.init(value: -1)
                print(node.offset)
                try! realm.write {
                    realm.add(model)
                }
            }
            
            print("config when first open")
        }
        
        
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
    }


}


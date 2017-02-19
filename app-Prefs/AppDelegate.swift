//
//  AppDelegate.swift
//  app-Prefs
//
//  Created by 成璐飞 on 2016/12/16.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD

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
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setMinimumDismissTimeInterval(1.5)
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.chengluffy.app-Prefs")
        let realmURL = container!.appendingPathComponent("defualt.realm")
        
        Realm.Configuration.defaultConfiguration.fileURL = realmURL
        let realm = try! Realm()
//        UserDefaults.standard.set(false, forKey: "isFirstOpen")
        if UserDefaults.standard.object(forKey: "isFirstOpen") == nil || UserDefaults.standard.object(forKey: "isFirstOpen") as! Bool == true  {
            
            
            UserDefaults.standard.set("default", forKey: "language")
            UserDefaults.standard.set(false, forKey: "isFirstOpen")
            
            let settings = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Settings", ofType: ".plist")!) as? Dictionary<String, AnyHashable>
            
            for dict in (settings?["settings"] as! Array<Dictionary<String, AnyHashable>>) {
                let model = Setting()
                model.name = dict["name"] as! String
                model.action = dict["action"] as! String
                model.isDeleted = dict["isDeleted"] as! Bool
                model.type = dict["type"] as! String
                model.sortNum = dict["sortNum"] as! NSNumber
                try! realm.write {
                    realm.add(model, update: true)
                }
            }
            
//            let systemSettings = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "SystemSettings", ofType: ".plist")!) as? Dictionary<String, String>
//            
//            for node in (systemSettings?.enumerated())! {
//                let model = Setting()
//                model.name = node.element.key
//                model.action = node.element.value
//                model.type = ActionType.system.rawValue
//                model.isDeleted = true
//                model.sortNum = NSNumber.init(value: -1)
//                print(node.offset)
//                try! realm.write {
//                    realm.add(model, update: true)
//                }
//            }
            
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

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url)
        
        let alertC = UIAlertController(title: SwitchLanguageTool.getLocalString(of: "Warning"), message: SwitchLanguageTool.getLocalString(of: "importWarning"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Cancel"), style: .cancel, handler: { (_) in
        })
        let sureAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Sure"), style: .destructive, handler: { (_) in
            
            if url.absoluteString.hasSuffix(".plist") {
                if let dict = NSDictionary(contentsOf: url) as? Dictionary<String, AnyObject> {
                    if dict.keys.contains("name") && dict.keys.contains("settings") {
                        if (dict["name"] as! String == "app-Prefs") && (dict["settings"]?.isKind(of: NSArray.self))! {
                            let tempArr = dict["settings"] as! NSArray
                            var ret = true
                            for tempDict in tempArr {
                                if (tempDict as AnyObject).isKind(of: NSDictionary.self) {
                                    if ((tempDict as! NSDictionary).allKeys as NSArray).contains("action") && ((tempDict as! NSDictionary).allKeys as NSArray).contains("name") && ((tempDict as! NSDictionary).allKeys as NSArray).contains("isDeleted") && ((tempDict as! NSDictionary).allKeys as NSArray).contains("sortNum") && ((tempDict as! NSDictionary).allKeys as NSArray).contains("type") {
                                        if ((tempDict as! NSDictionary)["action"] as AnyObject).isKind(of: NSString.self) && ((tempDict as! NSDictionary)["name"] as AnyObject).isKind(of: NSString.self) && ((tempDict as! NSDictionary)["type"] as AnyObject).isKind(of: NSString.self) && ((tempDict as! NSDictionary)["sortNum"] as AnyObject).isKind(of: NSNumber.self) && (((tempDict as! NSDictionary)["isDeleted"] as? Bool == false) || ((tempDict as! NSDictionary)["isDeleted"] as? Bool == true))  {
                                            
                                        } else {
                                            ret = false
                                        }
                                    } else {
                                        ret = false
                                    }
                                } else {
                                    ret = false
                                }
                            }
                            if ret != true {
                                self.alertWrongFormat()
                                return
                            }
                            let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.chengluffy.app-Prefs")
                            let realmURL = container!.appendingPathComponent("defualt.realm")
                            Realm.Configuration.defaultConfiguration.fileURL = realmURL
                            do {
                                let realm = try! Realm()
                                try realm.write {
                                    realm.deleteAll()
                                }
                                try realm.write {
                                    let arr = dict["settings"] as! Array<Dictionary<String, Any>>
                                    for subDict in arr {
                                        let model = Setting()
                                        model.action = subDict["action"] as! String
                                        model.name = subDict["name"] as! String
                                        model.isDeleted = subDict["isDeleted"] as! Bool
                                        model.sortNum = subDict["sortNum"] as! NSNumber
                                        model.type = subDict["type"] as! String
                                        print(model.name)
                                        realm.add(model)
                                    }
                                }
                                SVProgressHUD.showSuccess(withStatus: SwitchLanguageTool.getLocalString(of: "Success!"))
                            } catch {
                                print(error)
                                self.alertWrongFormat()
                            }
                            
                            ((self.window?.rootViewController as! UINavigationController).viewControllers.first as! ViewController).refresh()
                            try! FileManager.default.removeItem(at: url)
                        } else {
                            print("name' value isn't app-Prefs")
                            self.alertWrongFormat()
                            try! FileManager.default.removeItem(at: url)
                        }
                    } else {
                        print("no key: name")
                        self.alertWrongFormat()
                        try! FileManager.default.removeItem(at: url)
                    }

                } else {
                    self.alertWrongFormat()
                    try! FileManager.default.removeItem(at: url)
                }
            } else {
                print("not a plist file")
                self.alertWrongFormat()
                try! FileManager.default.removeItem(at: url)
            }
        })
        
        alertC.addAction(cancelAction)
        alertC.addAction(sureAction)
        
        window?.rootViewController?.present(alertC, animated: true, completion: nil)
        
        return true
    }
    
    func alertWrongFormat() {
        SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "WrongFormat"))
    }

}


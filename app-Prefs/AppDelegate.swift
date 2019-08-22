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
import UserNotifications
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = UIColor.white
        let nav = UINavigationController(rootViewController: ViewController())
        window?.rootViewController = nav
        
        setupIAP()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { (ret, error) in
            if ret == false {
//                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
            print(ret, error ?? "")
        }
        
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.chengluffy.app-Prefs")
        let realmURL = container!.appendingPathComponent("defualt.realm")
        
        Realm.Configuration.defaultConfiguration.fileURL = realmURL
        let realm = try! Realm()
        
        var isBiggerThan11: Bool
        let systemVersion = UIDevice.current.systemVersion as NSString
        isBiggerThan11 = systemVersion.floatValue >= 11.0
        
        if UserDefaults.standard.object(forKey: "isFirstOpen") == nil || UserDefaults.standard.object(forKey: "isFirstOpen") as! Bool == true  {
            
            
            UserDefaults.init(suiteName: "group.chengluffy.app-Prefs")?.set("default", forKey: "language")
            UserDefaults.standard.set(false, forKey: "isFirstOpen")
            
            let settings = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Settings", ofType: ".plist")!) as? Dictionary<String, AnyHashable>
            
            for dict in (settings?["settings"] as! Array<Dictionary<String, AnyHashable>>) {
                if isBiggerThan11 {
                    if dict["type"] as! String != "system" {
                        let model = Setting()
                        model.type = dict["type"] as! String
                        model.name = dict["name"] as? String
                        model.action = dict["action"] as? String
                        model.isDeleted = dict["isDeleted"] as! Bool
                        model.sortNum = dict["sortNum"] as! NSNumber
                        try! realm.write {
                            realm.add(model, update: true)
                        }
                    }
                } else {
                    let model = Setting()
                    model.type = dict["type"] as! String
                    model.name = dict["name"] as? String
                    model.action = dict["action"] as? String
                    model.isDeleted = dict["isDeleted"] as! Bool
                    model.sortNum = dict["sortNum"] as! NSNumber
                    try! realm.write {
                        realm.add(model, update: true)
                    }
                }
            }
            
            print("config when first open")
        }
        
        if realm.objects(Setting.self).filter("type == 'clipboard'").count == 0 {
            for i in 0...2 {
                let model = Setting()
                switch i {
                case 0:
                    model.name = "Open URL Scheme from Clipboard."
                    model.action = "Open URL Scheme from Clipboard."
                    break
                case 1:
                    model.name = "Search Keyword in Clipboard by Google."
                    model.action = "https://google.com/search?q="
                    break
                case 2:
                    model.name = "JSON tree view."
                    model.action = "FastOpenJSON://"
                    break
                default: break
                }
                model.type = ActionType.clipboard.rawValue
                model.sortNum = -1
                model.isDeleted = true
                try! realm.write {
                    realm.add(model, update: true)
                }
            }
        }
        
        
        return true
    }
    
    func setupIAP() {
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    fatalError()
                }
            }
        }
        
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            
            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.compactMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                print("Saving: \(contentURLs)")
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
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

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url)
        if url.absoluteString.hasPrefix("file://") {
            let alertC = UIAlertController(title: SwitchLanguageTool.getLocalString(of: "Warning"), message: SwitchLanguageTool.getLocalString(of: "importWarning"), preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Cancel"), style: .cancel, handler: { (_) in
            })
            let addAllAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Delete Local & Import All"), style: .destructive, handler: { (_) in
                let _ = ConfigTool.import(from: url, deleteAll: true)
            })
            let addNotExsitAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Only import Not Exsit"), style: .default, handler: { (_) in
                let _ = ConfigTool.import(from: url, deleteAll: false)
            })
            alertC.addAction(cancelAction)
            alertC.addAction(addAllAction)
            alertC.addAction(addNotExsitAction)
            
            (self.window?.rootViewController as! UINavigationController).popToRootViewController(animated: true)
            window?.rootViewController?.present(alertC, animated: true, completion: { 
            })
            
        } else if url.absoluteString.hasPrefix("FastOpenJSON://") {
            let textVC = TextViewController()
            textVC.urlStr = url
            (self.window?.rootViewController as! UINavigationController).pushViewController(textVC, animated: true)
        } else if url.absoluteString.hasPrefix("app-Prefs://") {
            if url.absoluteString == "app-Prefs://list" {
                let vc = ((self.window?.rootViewController as! UINavigationController).viewControllers.first as! ViewController)
                vc.segmentedControl.selectedSegmentIndex = 0
                if !vc.editClicked {
                    vc.displayMode = .display
                    vc.navigationItem.rightBarButtonItems = []
                    vc.navigationItem.rightBarButtonItem = vc.editBBI
                    vc.navigationItem.leftBarButtonItem = vc.settingBBI
                    vc.refresh()
                }
                (self.window?.rootViewController as! UINavigationController).popToRootViewController(animated: true)
            } else if url.absoluteString == "app-Prefs://cache" {
                let vc = ((self.window?.rootViewController as! UINavigationController).viewControllers.first as! ViewController)
                vc.segmentedControl.selectedSegmentIndex = 1
                if vc.editClicked == true {
                    SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "Please cancel or save your configuration."))
                    vc.segmentedControl.selectedSegmentIndex = 0
                } else {
                    vc.displayMode = .cache
                    vc.navigationItem.rightBarButtonItems = []
                    vc.navigationItem.rightBarButtonItem = vc.addBBI
                    vc.refresh()
                }
                (self.window?.rootViewController as! UINavigationController).popToRootViewController(animated: true)
            } else if url.absoluteString == "app-Prefs://new" {
                let vc = ((self.window?.rootViewController as! UINavigationController).viewControllers.first as! ViewController)
                vc.segmentedControl.selectedSegmentIndex = 1
                if vc.editClicked == true {
                    SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "Please cancel or save your configuration."))
                    vc.segmentedControl.selectedSegmentIndex = 0
                } else {
                    vc.displayMode = .cache
                    vc.navigationItem.rightBarButtonItems = []
                    vc.navigationItem.rightBarButtonItem = vc.addBBI
                    vc.refresh()
                }
                (self.window?.rootViewController as! UINavigationController).popToRootViewController(animated: false)
                let textInputVC = TextInputViewController()
                weak var weakSelf = ((self.window?.rootViewController as! UINavigationController).viewControllers.first as! ViewController)
                textInputVC.actionCanBeEdit = true
                textInputVC.reloadAction = {
                    weakSelf?.tableView.reloadData()
                }
                (self.window?.rootViewController as! UINavigationController).pushViewController(textInputVC, animated: true)
            }
        }
        
        
        return true
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}

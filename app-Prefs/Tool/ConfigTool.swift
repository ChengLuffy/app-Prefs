//
//  ConfigTool.swift
//  app-Prefs
//
//  Created by 成殿 on 2017/3/1.
//  Copyright © 2017年 成璐飞. All rights reserved.
//

import Foundation
import SVProgressHUD
import RealmSwift

class ConfigTool {
    
    class func backup() -> URL? {
        
        let realm = try! Realm()
        let dict = NSMutableDictionary()
        dict.setValue("app-Prefs", forKey: "name")
        
        let arr = NSMutableArray()
        
        let models = realm.objects(Setting.self)
        for model in models {
            let tempDict = NSMutableDictionary()
            tempDict.setValue(model.name, forKey: "name")
            tempDict.setValue(model.action, forKey: "action")
            tempDict.setValue(model.isDeleted, forKey: "isDeleted")
            tempDict.setValue(model.sortNum, forKey: "sortNum")
            tempDict.setValue(model.type, forKey: "type")
            arr.add(tempDict)
        }
        
        dict.setValue(arr, forKey: "settings")
        
        let tempPath = NSTemporaryDirectory()
        let path = tempPath+"/app-Prefs.plist"
        if FileManager.default.fileExists(atPath: path) {
            try! FileManager.default.removeItem(atPath: path)
        }
        let ret = dict.write(toFile: tempPath+"/app-Prefs.plist", atomically: true)
        print("write file result: \(ret)")
        
        if ret == true {
            return URL.init(fileURLWithPath: tempPath+"/app-Prefs.plist")
        } else {
            return nil
        }
        
    }
    
    class func `import`(from fileUrl: URL) -> Bool {
        
        if fileUrl.absoluteString.hasSuffix(".plist") {
            if let dict = NSDictionary(contentsOf: fileUrl) as? Dictionary<String, AnyObject> {
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
                            SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "WrongFormat"))
                            return false
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
                        } catch {
                            print(error)
                            SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "WrongFormat"))
                            return false
                        }
                        ((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as! UINavigationController).popToRootViewController(animated: true)
                        (((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as! UINavigationController).viewControllers.first as! ViewController).refresh()
                        try! FileManager.default.removeItem(at: fileUrl)
                        SVProgressHUD.showSuccess(withStatus: SwitchLanguageTool.getLocalString(of: "Success!"))
                        return true
                    } else {
                        print("name' value isn't app-Prefs")
                        SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "WrongFormat"))
                        try! FileManager.default.removeItem(at: fileUrl)
                        return false
                    }
                } else {
                    print("no key: name")
                    SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "WrongFormat"))
                    try! FileManager.default.removeItem(at: fileUrl)
                    return false
                }
                
            } else {
                SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "WrongFormat"))
                try! FileManager.default.removeItem(at: fileUrl)
                return false
            }
        } else {
            print("not a plist file")
            SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "WrongFormat"))
            try! FileManager.default.removeItem(at: fileUrl)
            return false
        }
        
    }
    
    class func deleteConfigCache() -> Bool {
        return true
    }
    
}

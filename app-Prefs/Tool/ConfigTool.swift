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
            tempDict.setValue(model.isHidden, forKey: "isHidden")
            tempDict.setValue(model.sortNum, forKey: "sortNum")
            tempDict.setValue(model.type, forKey: "type")
            arr.add(tempDict)
        }
        
        dict.setValue(arr, forKey: "settings")
        
        do {
            let json = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let tempPath = NSTemporaryDirectory()
            let path = tempPath+"app-Prefs.json"
            if FileManager.default.fileExists(atPath: path) {
                try! FileManager.default.removeItem(atPath: path)
            }
            do {
                try json.write(to: URL.init(fileURLWithPath: path), options: .atomic)
                print("write file result: \(path)")
                
                return URL.init(fileURLWithPath: path)
            } catch {
                print(error)
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                return nil
            }
            
            
        } catch {
            print(error)
            SVProgressHUD.showError(withStatus: error.localizedDescription)
            return nil
        }
        
    }
    
    class func `import`(from fileUrl: URL, deleteAll: Bool) -> Bool {
        
        if fileUrl.absoluteString.hasSuffix(".plist") {
            if let dict = NSDictionary(contentsOf: fileUrl) as? Dictionary<String, AnyObject> {
                let _ = dealWith(imput: dict, deleteAll: deleteAll)
                try! FileManager.default.removeItem(at: fileUrl)
                return true
            } else {
                SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "WrongFormat"))
                try! FileManager.default.removeItem(at: fileUrl)
                return false
            }
        } else if fileUrl.absoluteString.hasSuffix(".json"){
            do {
                let data = try Data.init(contentsOf: fileUrl)
                let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let ret = dealWith(imput: dict as! Dictionary<String, AnyObject>, deleteAll: deleteAll)
                if ret == true {
                    try! FileManager.default.removeItem(at: fileUrl)
                    return true
                } else {
                    return false
                }
                
            } catch {
                print(error)
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                return false
            }
        } else {
            print("not a plist/json file")
            SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "WrongFormat"))
            try! FileManager.default.removeItem(at: fileUrl)
            return false
        }
        
    }
    
    class func resetConfig() -> Bool {
        
        let realm = try! Realm()
        try! realm.write {
            let local = realm.objects(Setting.self)
            local.forEach({ (model) in
                model.isDeleted = true
            })
        }
        let settings = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Settings", ofType: ".plist")!) as? Dictionary<String, AnyHashable>
        
        for dict in (settings?["settings"] as! Array<Dictionary<String, AnyHashable>>) {
            let model = Setting()
            model.name = dict["name"] as? String
            model.action = dict["action"] as? String
            model.isHidden = dict["isHidden"] as! Bool
            model.type = dict["type"] as! String
            model.sortNum = dict["sortNum"] as! NSNumber
            try! realm.write {
//                realm.add(model, update: true)
                realm.add(model, update: .all)
            }
        }

        
        return true
    }
    
    fileprivate class func dealWith(imput dict: Dictionary<String, AnyObject>, deleteAll: Bool) -> Bool {
        if dict.keys.contains("name") && dict.keys.contains("settings") {
            if (dict["name"] as! String == "app-Prefs") && (dict["settings"]?.isKind(of: NSArray.self))! {
                let tempArr = dict["settings"] as! NSArray
                var ret = true
                for tempDict in tempArr {
                    if (tempDict as AnyObject).isKind(of: NSDictionary.self) {
                        if ((tempDict as! NSDictionary).allKeys as NSArray).contains("action") && ((tempDict as! NSDictionary).allKeys as NSArray).contains("name") && ((tempDict as! NSDictionary).allKeys as NSArray).contains("sortNum") && ((tempDict as! NSDictionary).allKeys as NSArray).contains("type") {
                            if ((tempDict as! NSDictionary)["action"] as AnyObject).isKind(of: NSString.self) && ((tempDict as! NSDictionary)["name"] as AnyObject).isKind(of: NSString.self) && ((tempDict as! NSDictionary)["type"] as AnyObject).isKind(of: NSString.self) && ((tempDict as! NSDictionary)["sortNum"] as AnyObject).isKind(of: NSNumber.self)  {
                                
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
                    if deleteAll == true {
                        try realm.write {
                            let local = realm.objects(Setting.self)
                            local.forEach({ (model) in
                                model.isDeleted = true
                            })
                        }
                        try realm.write {
                            realm.deleteAll()
                        }
                        try realm.write {
                            let arr = dict["settings"] as! Array<Dictionary<String, Any>>
                            for subDict in arr {
                                let model = Setting()
                                model.action = (subDict["action"] as! String)
                                model.name = (subDict["name"] as! String)
                                if subDict.keys.contains("isHidden") {
                                    model.isHidden = subDict["isHidden"] as! Bool
                                } else {
                                    model.isHidden = subDict["isDeleted"] as! Bool
                                }
                                model.sortNum = subDict["sortNum"] as! NSNumber
                                model.type = subDict["type"] as! String
                                realm.add(model, update: .modified)
                            }
                        }
                    } else {
                        try realm.write {
                            let arr = dict["settings"] as! Array<Dictionary<String, Any>>
                            for subDict in arr {
                                print(realm.objects(Setting.self).filter("action = '\(subDict["action"] as? String ?? "")'"))
                                if (subDict["action"] as? String ?? "").count > 100 || realm.objects(Setting.self).filter("action = '\(subDict["action"] as? String ?? "")'").count == 0 {
                                    let model = Setting()
                                    model.action = (subDict["action"] as! String)
                                    if realm.objects(Setting.self).filter("name = '\(subDict["name"] as! String)'").count == 0 {
                                        model.name = (subDict["name"] as! String)
                                    } else {
                                        var temp = true
                                        var name = ""
                                        var i = 0
                                        while temp {
                                            if realm.objects(Setting.self).filter("name = '\((subDict["name"] as! String) + "\(i)")'").count == 0 {
                                                name = (subDict["name"] as! String) + "\(i)"
                                                temp = false
                                            } else {
                                                i = i + 1
                                            }
                                        }
                                        model.name = name
                                    }
                                    model.isHidden = true
                                    model.sortNum = -1
                                    model.type = subDict["type"] as! String
                                    realm.add(model, update: .all)
                                }
                            }
                        }
                    }
                    
                } catch {
                    print(error)
                    SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "WrongFormat"))
                    return false
                }
                (((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as! UINavigationController).viewControllers.first as! ViewController).refresh()
                
                SVProgressHUD.showSuccess(withStatus: SwitchLanguageTool.getLocalString(of: "Success!"))
                return true
            } else {
                print("name' value isn't app-Prefs")
                SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "WrongFormat"))
                return false
            }
        } else {
            print("no key: name")
            SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "WrongFormat"))
            return false
        }
    }
    
}

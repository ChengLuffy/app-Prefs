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
    
    class func `import`(from fileUrl: URL) {
        
    }
    
    class func deleteConfigCache() -> Bool {
        return true
    }
    
}

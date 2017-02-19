//
//  SwitchLanguagesTool.swift
//  app-Prefs
//
//  Created by 成殿 on 2017/2/19.
//  Copyright © 2017年 成璐飞. All rights reserved.
//

import Foundation

class SwitchLanguageTool {
    
    private let Chinese = "zh-Hans"
    private let English = "en"
    
    private class func getBundle(of language: String) -> Bundle {
        if language == "default" {
            return Bundle.main
        } else {
            let path = Bundle.main.path(forResource: language, ofType: "lproj")
            let bundle = Bundle.init(path: path!)
            return bundle!
        }
    }
    
    class func getLocalString(of string: String) -> String {
        let userDefaults = UserDefaults.init(suiteName: "group.chengluffy.app-Prefs")
        var str = userDefaults?.value(forKey: "language") as? String
        if str == nil {
            str = "default"
        }
        let bundle = getBundle(of: str!)
        return bundle.localizedString(forKey: string, value: nil, table: "Localizable")
    }
    
}

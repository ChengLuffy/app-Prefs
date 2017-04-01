//
//  ClipboardActionTool.swift
//  app-Prefs
//
//  Created by 成殿 on 2017/4/1.
//  Copyright © 2017年 成璐飞. All rights reserved.
//

import UIKit

class ClipboardActionTool {
    
    class func performAction(_ action: String) -> String {
        
        let str = UIPasteboard.general.string ?? ""
        var realAction: String = ""
        switch action {
        case "Open URL Scheme from Clipboard.":
            let dataDetector = try! NSDataDetector(types:
                NSTextCheckingTypes(NSTextCheckingResult.CheckingType.link.rawValue))
            let res = dataDetector.matches(in: str,
                                           options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                           range: NSMakeRange(0, str.characters.count)).first?.range
            let tempStr = NSString.init(string: str)
            if res != nil {
                let urlStr = tempStr.substring(with: res!)
                realAction = urlStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            } else {
                if tempStr.contains(":") {
                    realAction = tempStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                }
            }
            break
        case "https://google.com/search?q=":
            realAction = action + str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            break
        case "https://zh.wikipedia.org/wiki/":
            realAction = action + str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            break
        case "https://en.wikipedia.org/wiki/":
            realAction = action + str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            break
        case "https://bing.com/search?q=":
            realAction = action + str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            break
        case "https://s.m.taobao.com/h5?q=":
            realAction = action + str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            break
        case "FastOpenJSON://":
            realAction = "FastOpenJSON://" + str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            break
        default:
            realAction = ""
            break
        }

        
        return realAction
    }
    
    class func getAllClipActions() -> [String: String] {
        
        return [
            "Search Keyword in Clipboard by Google.": "https://google.com/search?q=",
            "Search Keyword in Clipboard by Bing.": "https://bing.com/search?q=",
            "Search Keyword in Clipboard by Wiki.": "https://zh.wikipedia.org/wiki/",
            "Search Keyword in Clipboard by Taobao.": "https://s.m.taobao.com/h5?q=",
            "Open URL Scheme from Clipboard.": "Open URL Scheme from Clipboard.",
            "JSON tree view.": "FastOpenJSON://"]
        
    }
    
}

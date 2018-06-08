//
//  ClipboardActionTool.swift
//  app-Prefs
//
//  Created by 成殿 on 2017/4/1.
//  Copyright © 2017年 成璐飞. All rights reserved.
//

import UIKit
import UserNotifications
import SVProgressHUD

class ClipboardActionTool {
    
    class func performAction(_ action: String) -> String {
        
        let str = UIPasteboard.general.string ?? ""
        var realAction: String = ""
        switch action.removingPercentEncoding! {
        case "Open URL Scheme from Clipboard.":
            let dataDetector = try! NSDataDetector(types:
                NSTextCheckingTypes(NSTextCheckingResult.CheckingType.link.rawValue))
            let res = dataDetector.matches(in: str,
                                           options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                           range: NSMakeRange(0, str.count)).first?.range
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
        case "Show content in clipboard":
            realAction = ""
            
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = SwitchLanguageTool.getLocalString(of: "Content in Clipboard")
            
            if UIPasteboard.general.hasStrings && UIPasteboard.general.string != "" {
                content.body = str
            }
            
            if UIPasteboard.general.hasImages {
                content.body = SwitchLanguageTool.getLocalString(of: "image")
                let image = UIPasteboard.general.image
                let data = NSData(data: UIImageJPEGRepresentation(image!, 1)!)
                let url = NSURL(fileURLWithPath: NSTemporaryDirectory()+"/notification.jpg")
                data.write(to: url as URL, atomically: true)
                let attachment = try! UNNotificationAttachment.init(identifier: "file", url: url as URL, options: nil)
                content.attachments = [attachment]
            }
            
            content.sound = UNNotificationSound.default()
            
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0.1, repeats: false)
            let request = UNNotificationRequest.init(identifier: "clipboard", content: content, trigger: trigger)
            center.add(request, withCompletionHandler: { (error) in
                print(error ?? "nil")
                guard error == nil else {
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    return
                }
            })
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
            "JSON tree view.": "FastOpenJSON://",
            "Show content in clipboard": "Show content in clipboard"]
        
    }
    
}

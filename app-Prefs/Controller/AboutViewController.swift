//  )=======_.:   .. . . ..  .   . ... ..`..: ::.:.::.. :... ... :..._xX====X==
//  )o=========X1.__,._..:  .  .    . . .. .          ..._.,,:xs_x==X=X========
//  )n===========X====X}     .-qag, .  .   . . ._qaaa`..  .uX======X===========
//  )n================'.   .  .)xXXmmmme*mm##mmmmm##Z     .x===================
//  )o===============^.   .  . ]g{???V?m{m#Z#SZT#XY?'.     )===================
//  )o==============r   . qp    )s\]"$bw]#m7#m#P^a\r.   _g; $=X================
//  )n==============[     ."5a   -4%(ggg,)(,_ggg7a(   qJ? .::?X================
//  )n==========XXr-.   .    "Aa   "b<w##?!4mmmS2`  qJ?`  .  :{uX==============
//  )=========I-- .       . . `!#a  )NX#P-p4##Z^  aw?-. .    .-=-<X============
//  )n====r-^ . .   .   .       ~Y#a  )4b  Jm?  qmY>`        . :.  .+--{X======
//  )n}-. . .    . .   .      .   <Y#g.    .  aZU}'    .  . .          . --*===
//  )^.        .           . .   . ]5?Wa    am!^`                 .     ..  .+<
//        .  .      .  .  .     .    -;!#agW7`-.       . .    . .    . .   .
//      .       .  .     .             .a#P`,.             .       .         .
//     .   . .         .     .   .  . a#Y5s)WLp     .  .     .   .   .  . .
//    .         . .        .  .,   .gWZ(/' ?iY#L,  ._,    .    .             .
//       .  .  .     . .     .],._ao21P'    /4{1Xap _f.  .   .     . . . .  .
//      .           .     ._._g)5#ZXo~        -{dZXo!sgg,   .   . .
//    .     .  .  .    .  .;-H3~9p)^qag^  . ]qgg?\_@^53( . ,.  .           .
//      .  .         .:_<#I(+(==,-^`<,.. .   .jp ^`.,=+`<)qp,;      . . .    .
//     .      .  . . ;=uK{=+|._:=.. .-.     . .   .`=:_(=|+Ju>,.  .        .
//    .     .   .   ::;===I._*(  .  .     .      . .._S===cj+' =       .     .
//        .    .      - /-9'.:. .  .   . .     .     . :.~?:.--.  .  .    .
//                 . <qa"'. .   .     .      .   . .  .  .-^ggp        .    .
//
//  AboutViewController.swift
//  app-Prefs
//
//  Created by 成殿 on 2017/2/5.
//  Copyright © 2017年 成璐飞. All rights reserved.
//

import UIKit
import RealmSwift
import MessageUI
import SVProgressHUD

// MARK: - display cells
// reset
// export & share
// import form URL
// email me to ask a Application's recommended settings

class AboutViewController: UIViewController {
    
    var documentController: UIDocumentInteractionController?
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        
        view.addSubview(tableView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AboutViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 7 : 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        cell?.accessoryType = .disclosureIndicator
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell?.textLabel?.text = SwitchLanguageTool.getLocalString(of: "Reset Config.")
                cell?.detailTextLabel?.text = SwitchLanguageTool.getLocalString(of: "Reset to you first installed App's config.")
            case 1:
                cell?.textLabel?.text = SwitchLanguageTool.getLocalString(of: "Share Config.")
                cell?.detailTextLabel?.text = SwitchLanguageTool.getLocalString(of: "Export config to a plist file and share it.")
            case 2:
                cell?.textLabel?.text = SwitchLanguageTool.getLocalString(of: "Download Config.")
                cell?.detailTextLabel?.text = SwitchLanguageTool.getLocalString(of: "Download a config.")
            case 3:
                cell?.textLabel?.text = SwitchLanguageTool.getLocalString(of: "Wanted Help.")
                cell?.detailTextLabel?.text = SwitchLanguageTool.getLocalString(of: "Email me or open a issue in github.")
            case 4:
                cell?.textLabel?.text = SwitchLanguageTool.getLocalString(of: "Switch Languages.")
                cell?.detailTextLabel?.text = SwitchLanguageTool.getLocalString(of: "Default, Chinese or English.")
            case 5:
                cell?.textLabel?.text = SwitchLanguageTool.getLocalString(of: "Instructions for use.")
            case 6:
                cell?.textLabel?.text = SwitchLanguageTool.getLocalString(of: "Click Vibrate.")
                cell?.detailTextLabel?.text = SwitchLanguageTool.getLocalString(of: "Need phone open shock setting.")
                
                if UserDefaults.init(suiteName: "group.chengluffy.app-Prefs")?.value(forKey: "shock") == nil || UserDefaults.init(suiteName: "group.chengluffy.app-Prefs")?.value(forKey: "shock") as! Bool == true {
                    cell?.accessoryType = .checkmark
                } else {
                    cell?.accessoryType = .none
                }
                
            default: break
            }
        } else {
            switch indexPath.row {
            case 0:
                cell?.textLabel?.text = SwitchLanguageTool.getLocalString(of: "致谢 @StackOverflowError")
                cell?.detailTextLabel?.text = SwitchLanguageTool.getLocalString(of: "")
            case 1:
                cell?.textLabel?.text = SwitchLanguageTool.getLocalString(of: "app-tutorials")
                cell?.detailTextLabel?.text = SwitchLanguageTool.getLocalString(of: "app-tutorials is is the basis FastOpen")
            case 2:
                cell?.textLabel?.text = SwitchLanguageTool.getLocalString(of: "Retriever")
                cell?.detailTextLabel?.text = SwitchLanguageTool.getLocalString(of: "Retriever is An effective tool for finding App's URL-Schemes")
            case 3:
                cell?.textLabel?.text = SwitchLanguageTool.getLocalString(of: "Pin")
                cell?.detailTextLabel?.text = SwitchLanguageTool.getLocalString(of: "Pin is a amazing Application.")
            default: break
            }
        }
        cell?.detailTextLabel?.adjustsFontSizeToFitWidth = true
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let realm = try! Realm()
            
            switch indexPath.row {
            case 0:
                // reset
                
                let alertC = UIAlertController(title: SwitchLanguageTool.getLocalString(of: "Warning"), message: SwitchLanguageTool.getLocalString(of: "ReserWarning"), preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Cancel"), style: .cancel, handler: { (_) in
                })
                let sureAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Sure"), style: .destructive, handler: { (_) in
                    
                    SVProgressHUD.show()
                    
                    let ret = ConfigTool.resetConfig()
                    if ret == true {
                        SVProgressHUD.showSuccess(withStatus: SwitchLanguageTool.getLocalString(of: "Success!"))
                    } else {
                        SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "Error!"))
                    }
                    
                })
                
                alertC.addAction(sureAction)
                alertC.addAction(cancelAction)
                
                present(alertC, animated: true, completion: {
                })
                
                break
            case 1:
                // share
                SVProgressHUD.show()
                if let url = ConfigTool.backup() {
                    SVProgressHUD.dismiss()
                    print(url)
                    documentController = UIDocumentInteractionController(url: url)
                    documentController!.presentOptionsMenu(from: view.bounds, in: view, animated: true)
                } else {
                    SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "exportError"))
                }
                break
            case 2:
                
                // download
                var textField: UITextField?
                let alertC = UIAlertController(title: SwitchLanguageTool.getLocalString(of: "Download"), message: SwitchLanguageTool.getLocalString(of: "please type config's URL"), preferredStyle: .alert)
                alertC.addTextField(configurationHandler: { (tf) in
                    textField = tf
                })
                let cancelAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Cancel"), style: .cancel, handler: { (_) in
                })
                let sureAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Sure"), style: .destructive, handler: { (_) in
                    SVProgressHUD.show()
                    let sessionConfig = URLSessionConfiguration.default
                    let session = URLSession(configuration: sessionConfig)
                    let task = session.downloadTask(with: URL.init(string: (textField?.text!)!)!, completionHandler: { (url, response, error) in
                        print(url ?? error ?? "nil")
                        if error != nil {
                            SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: error!.localizedDescription))
                            print(error!.localizedDescription)
                            return
                        }
                        var path = ""
                        if (textField?.text?.hasSuffix(".plist"))! {
                            path = NSTemporaryDirectory()+"app-Prefs.plist"
                        } else {
                            path = NSTemporaryDirectory()+"app-Prefs.json"
                        }
                        
                        if FileManager.default.fileExists(atPath: path) {
                            try! FileManager.default.removeItem(atPath: path)
                        }
                        try! FileManager.default.moveItem(at: url!, to: URL.init(fileURLWithPath: path))
                        let fileUrl = URL.init(fileURLWithPath: path)
                        SVProgressHUD.dismiss()
                        let alertC = UIAlertController(title: SwitchLanguageTool.getLocalString(of: "Warning"), message: SwitchLanguageTool.getLocalString(of: "importWarning"), preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Cancel"), style: .cancel, handler: { (_) in
                        })
                        let addAllAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Delete Local & Import All"), style: .destructive, handler: { (_) in
                            let _ = ConfigTool.import(from: fileUrl, deleteAll: true)
                        })
                        let addNotExsitAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Only import Not Exsit"), style: .default, handler: { (_) in
                            let _ = ConfigTool.import(from: fileUrl, deleteAll: false)
                        })
                        alertC.addAction(cancelAction)
                        alertC.addAction(addAllAction)
                        alertC.addAction(addNotExsitAction)
                        
                        self.present(alertC, animated: true, completion: {
                        })
                    })
                    task.resume()
                })
                alertC.addAction(cancelAction)
                alertC.addAction(sureAction)
                present(alertC, animated: true, completion: nil)
                break
            case 3:
                // Help.
                
                let alertSheet = UIAlertController(title: SwitchLanguageTool.getLocalString(of: "click to selected"), message: SwitchLanguageTool.getLocalString(of: "askSettingsWarning"), preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Cancel"), style: .cancel, handler: { (_) in
                })
                let emailAction = UIAlertAction(title: "E-mail", style: .default, handler: { (_) in
                    
                    if MFMailComposeViewController.canSendMail() {
                        
                        let mailC = MFMailComposeViewController()
                        mailC.mailComposeDelegate = self
                        mailC.setToRecipients(["chengluffy@hotmail.com"])
                        mailC.setSubject("app-Prefs Help")
                        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
                        let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"]
                        
                        mailC.setMessageBody("system version:\(UIDevice.current.systemVersion), application version:\(version!)-\(buildVersion!)", isHTML: false)
                        
                        self.present(mailC, animated: true, completion: nil)
                        
                    } else {
                        self.alertWrongFormat("accountErrors")
                    }
                    
                })
                let issuesAction = UIAlertAction(title: "Issues", style: .destructive, handler: { (_) in
                    
                    let str = "https://chengluffy.github.io/app-Prefs/"
                    let url = URL.init(string: str)
                    UIApplication.shared.open(url!, options: [:], completionHandler: { (ret) in
                        print(ret)
                    })
                    
                })
                
                alertSheet.addAction(cancelAction)
                alertSheet.addAction(emailAction)
                alertSheet.addAction(issuesAction)
                
                present(alertSheet, animated: true, completion: {
                })
                break
            case 4:
                
                // Switch Language.
                let alertC = UIAlertController(title: SwitchLanguageTool.getLocalString(of: "Switch Languages."), message: nil, preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Cancel"), style: .cancel, handler: { (_) in
                })
                
                let defaultLanguage = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Default"), style: .default, handler: { (_) in
                    UserDefaults.init(suiteName: "group.chengluffy.app-Prefs")?.set("default", forKey: "language")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let _ = self.navigationController?.popToRootViewController(animated: true)
                    let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC")
                    (appDelegate.window?.rootViewController as! UINavigationController).viewControllers = [vc]
                })
                let EnglishLanguage = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "English"), style: .default, handler: { (_) in
                    UserDefaults.init(suiteName: "group.chengluffy.app-Prefs")?.set("en", forKey: "language")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let _ = self.navigationController?.popToRootViewController(animated: true)
                    let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC")
                    (appDelegate.window?.rootViewController as! UINavigationController).viewControllers = [vc]
                })
                let ChineseLanguage = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Chinese"), style: .default, handler: { (_) in
                    UserDefaults.init(suiteName: "group.chengluffy.app-Prefs")?.set("zh-Hans", forKey: "language")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let _ = self.navigationController?.popToRootViewController(animated: true)
                    let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC")
                    (appDelegate.window?.rootViewController as! UINavigationController).viewControllers = [vc]
                })
                alertC.addAction(cancelAction)
                alertC.addAction(defaultLanguage)
                alertC.addAction(EnglishLanguage)
                alertC.addAction(ChineseLanguage)
                present(alertC, animated: true, completion: { 
                })
                break
            case 5:
                let url = URL.init(string: "https://chengluffy.github.io/2017/06/13/快捷方式app简单使用说明/".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
                UIApplication.shared.open(url!, options: [:]) { (ret) in
                }
                break
            case 6:
                
                if UserDefaults.init(suiteName: "group.chengluffy.app-Prefs")?.value(forKey: "shock") == nil || UserDefaults.init(suiteName: "group.chengluffy.app-Prefs")?.value(forKey: "shock") as! Bool == true {
                    UserDefaults.init(suiteName: "group.chengluffy.app-Prefs")?.set(false, forKey: "shock")
                } else {
                    UserDefaults.init(suiteName: "group.chengluffy.app-Prefs")?.set(true, forKey: "shock")
                }
                tableView.reloadData()
                break
            default: break
            }
        } else {
            var action = ""
            if indexPath.row == 0 {
                action = "http://weibo.com/0x00eeee"
            } else if indexPath.row == 1 {
                action = "https://github.com/cyanzhong/app-tutorials/blob/master/schemes.md"
            } else if indexPath.row == 2 {
                action = "https://github.com/cyanzhong/Retriever"
            } else if indexPath.row == 3 {
                action = "https://itunes.apple.com/cn/app/pin-%E5%89%AA%E8%B4%B4%E6%9D%BF%E6%89%A9%E5%B1%95/id1039643846?mt=8"
            }
            let url = URL.init(string: action)
            UIApplication.shared.open(url!, options: [:]) { (ret) in
            }
            
        }
        
    }
    
    func alertWrongFormat(_ msg: String) {
        
        SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: msg))
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 75
        } else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 75))
            let aboutTV = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
            aboutTV.isEditable = false
            aboutTV.backgroundColor = UIColor.clear
            
            let displayText = SwitchLanguageTool.getLocalString(of: "Info")
            let attrStr = NSMutableAttributedString(string: displayText)
            
            let url = URL.init(string: "https://github.com/ChengLuffy/app-Prefs")
            
            let linkStr = "ChengLuffy/app-Prefs"
            let rang = displayText.range(of: linkStr)
            let location: Int = displayText.distance(from: displayText.startIndex, to: rang!.lowerBound)
            
            attrStr.addAttribute(NSLinkAttributeName, value: url!, range: NSRange.init(location: location, length: linkStr.characters.count))
            aboutTV.attributedText = attrStr
            aboutTV.textAlignment = .center
            aboutTV.delegate = self
            aboutTV.isUserInteractionEnabled = true
            aboutTV.isScrollEnabled = false
            aboutTV.center = view.center
            view.addSubview(aboutTV)
            
            return view
        } else {
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Thanks"
        } else {
            return nil
        }
    }
    
}

extension AboutViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:]) { (ret) in
        }
        return true
    }
}

extension AboutViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}

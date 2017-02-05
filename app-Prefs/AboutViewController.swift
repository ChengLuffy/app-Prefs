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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        cell?.accessoryType = .disclosureIndicator
        switch indexPath.row {
        case 0:
            cell?.textLabel?.text = "Reset config."
            cell?.detailTextLabel?.text = "Reset to you first installed App's config."
        case 1:
            cell?.textLabel?.text = "Share config."
            cell?.detailTextLabel?.text = "Export config to a json file and share it."
        case 2:
            cell?.textLabel?.text = "Download config"
            cell?.detailTextLabel?.text = "Download a config."
        case 3:
            cell?.textLabel?.text = "Email me."
            cell?.detailTextLabel?.text = "Email me for a Application's recommended setting."
        default: break
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let realm = try! Realm()
        
        switch indexPath.row {
        case 0:
            // reset
            
            let alertC = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("ReserWarning", comment: ""), preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (_) in
            })
            let sureAction = UIAlertAction(title: NSLocalizedString("Sure", comment: ""), style: .destructive, handler: { (_) in
                try! realm.write {
                    realm.deleteAll()
                }
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
                        realm.add(model, update: true)
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
                        realm.add(model, update: true)
                    }
                }

            })
            
            alertC.addAction(sureAction)
            alertC.addAction(cancelAction)
            
            present(alertC, animated: true, completion: {
            })
            
            break
        case 1:
            // share
            
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
            print(ret)
            
            if ret == true {
                documentController = UIDocumentInteractionController(url: URL.init(fileURLWithPath: path))
                documentController!.presentOptionsMenu(from: view.bounds, in: view, animated: true)
            }
            
            print(tempPath)
            break
        case 2:
            var textField: UITextField?
            let alertC = UIAlertController(title: "Download", message: "please type config's URL", preferredStyle: .alert)
            alertC.addTextField(configurationHandler: { (tf) in
                textField = tf
            })
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (_) in
            })
            let sureAction = UIAlertAction(title: NSLocalizedString("Sure", comment: ""), style: .destructive, handler: { (_) in
                let sessionConfig = URLSessionConfiguration.default
                let session = URLSession(configuration: sessionConfig)
                let task = session.downloadTask(with: URL.init(string: (textField?.text!)!)!, completionHandler: { (url, response, error) in
                    print(url)
                    try! FileManager.default.moveItem(at: url!, to: URL.init(string: NSTemporaryDirectory()+"app-Prefs.plist")!)
                })
                task.resume()
            })
            alertC.addAction(cancelAction)
            alertC.addAction(sureAction)
            present(alertC, animated: true, completion: nil)
            
            break
        default: break
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 75))
        let aboutTV = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        aboutTV.isEditable = false
        aboutTV.backgroundColor = UIColor.clear
        
        let displayText = "An Application what I just want make.\rYou can find whole open-source in Github: ChengLuffy/app-Prefs.\rThanks installed!"
        let attrStr = NSMutableAttributedString(string: displayText)
        
        let url = URL.init(string: "https://github.com/ChengLuffy/app-Prefs")
        
        attrStr.addAttribute(NSLinkAttributeName, value: url!, range: NSRange.init(location: 80, length: 20))
        aboutTV.attributedText = attrStr
        aboutTV.textAlignment = .center
        aboutTV.delegate = self
        aboutTV.isUserInteractionEnabled = true
        aboutTV.center = view.center
        view.addSubview(aboutTV)
        
        return view
    }
    
}

extension AboutViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:]) { (ret) in
        }
        return true
    }
}

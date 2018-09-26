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
//  TextInputViewController.swift
//  app-Prefs
//
//  Created by 成殿 on 2017/1/21.
//  Copyright © 2017年 成璐飞. All rights reserved.
//

import UIKit
import RealmSwift

class TextInputViewController: UIViewController {
    
    var reloadAction: (() -> ())?
    var name = ""
    var action = ""
    var modelIsDeleted: Bool = true
    var sortNum: NSNumber = -1
    var cate: String = SwitchLanguageTool.getLocalString(of: "Tap to Select.")
    var isEdit = false
    var actionCanBeEdit = false

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: .grouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "typeCell")
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Done"), style: .done, target: self, action: #selector(TextInputViewController.doneItemDidClicked(_:)))
        view.addSubview(tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapticEngine() {
        if UserDefaults.init(suiteName: "group.chengluffy.app-Prefs")?.value(forKey: "shock") == nil || UserDefaults.init(suiteName: "group.chengluffy.app-Prefs")?.value(forKey: "shock") as! Bool == true {
            let generator = UIImpactFeedbackGenerator.init(style: .light)
            generator.prepare()
            generator.impactOccurred()
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func doneItemDidClicked(_ sender: AnyObject) {
        tapticEngine()
        let titleCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! TextFieldCell
        let actionCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! TextFieldCell
        
        var msg = ""
        if titleCell.textField.text == "" {
            msg = SwitchLanguageTool.getLocalString(of: "please input the title")
        } else if actionCell.textField.text == "" {
            msg = SwitchLanguageTool.getLocalString(of: "please input the action")
        } else if cate == SwitchLanguageTool.getLocalString(of: "Tap to Select.") {
            msg = SwitchLanguageTool.getLocalString(of: "please select action's type")
        }
        if msg != "" {
            let alert = UIAlertController(title: SwitchLanguageTool.getLocalString(of: "Warning"), message: msg, preferredStyle: .alert)
            present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1, execute: {
                    alert.dismiss(animated: true, completion: {
                    })
                })
            }
        } else {
            let realm = try! Realm()
            
            if realm.objects(Setting.self).filter("name = '\(titleCell.textField.text!)'").count != 0 && isEdit == false {
                let alert = UIAlertController(title: "Warning", message: "Can't create object with existing primary key value '\(titleCell.textField.text!)'", preferredStyle: .alert)
                present(alert, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.5, execute: {
                        alert.dismiss(animated: true, completion: {
                        })
                    })
                }
            } else {
                let model = Setting()
                model.sortNum = sortNum
                model.isDeleted = modelIsDeleted
                model.name = titleCell.textField.text
                model.action = actionCell.textField.text?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                model.type = cate
                
                if model.name != name {
                    try! realm.write {
                        realm.delete(realm.objects(Setting.self).filter("name = '\(name)'"))
                    }
                }
                
                try! realm.write {
                    realm.add(model, update: true)
                }
                
                reloadAction!()
                
                navigationController!.popViewController(animated: true)

            }
            
        }
        
    }

    func selectClipboardAction() {
        let actionCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! TextFieldCell
        let clipboardSheet = UIAlertController(title: SwitchLanguageTool.getLocalString(of: "Select an action"), message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Cancel"), style: .cancel, handler: { (_) in
        })
        clipboardSheet.addAction(cancel)
        
        let actions = ClipboardActionTool.getAllClipActions()
        
        for node in actions.enumerated() {
            let action = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: node.element.key), style: .default, handler: { (_) in
                actionCell.textField.text = node.element.value
            })
            clipboardSheet.addAction(action)
        }
        
        present(clipboardSheet, animated: true, completion: {
        })
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

extension TextInputViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "cateCell")
            if cell == nil {
                cell = UITableViewCell.init(style: .value1, reuseIdentifier: "cateCell")
            }
            cell?.textLabel?.text = SwitchLanguageTool.getLocalString(of: " category:")
            if cate == ActionType.clipboard.rawValue {
                cell?.detailTextLabel?.text = SwitchLanguageTool.getLocalString(of: "Clipboard Action")
            } else {
                cell?.detailTextLabel?.text = SwitchLanguageTool.getLocalString(of: cate)
            }
            
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "typeCell", for: indexPath) as! TextFieldCell
            cell.titleLabel.text = indexPath.row == 1 ? SwitchLanguageTool.getLocalString(of: "title:") : SwitchLanguageTool.getLocalString(of: "action:")
            cell.textField.text = indexPath.row == 1 ? SwitchLanguageTool.getLocalString(of: name) : action
            if indexPath.row == 2 {
                cell.textField.autocorrectionType = .no
                cell.textField.autocapitalizationType = .none
                cell.textField.isEnabled = actionCanBeEdit
            }
            
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 150))
        let label = UILabel(frame: CGRect(x: 25, y: 10, width: UIScreen.main.bounds.width - 50, height: 130))
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = SwitchLanguageTool.getLocalString(of: "help")
        view.addSubview(label)
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowColor = UIColor.red.cgColor
        view.layer.shadowOpacity = 0.5
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer({
            let tap = UITapGestureRecognizer(target: self, action: #selector(TextInputViewController.hideKeyboard))
            return tap
        }())
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
            let cateSheet = UIAlertController(title: SwitchLanguageTool.getLocalString(of: "select your action category"), message: nil, preferredStyle: .actionSheet)
            let cancel = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Cancel"), style: .cancel, handler: { (_) in
                
            })
            let system = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Syetem Action"), style: .default, handler: { (_) in
                self.cate = ActionType.system.rawValue
                cell?.detailTextLabel?.text = SwitchLanguageTool.getLocalString(of: "Syetem Action")
                let actionCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! TextFieldCell
                actionCell.textField.isEnabled = true
            })
            let custom = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Custom Action"), style: .default, handler: { (_) in
                self.cate = ActionType.custom.rawValue
                cell?.detailTextLabel?.text = SwitchLanguageTool.getLocalString(of: "Custom Action")
                let actionCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! TextFieldCell
                actionCell.textField.isEnabled = true
            })
            let clipboard = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Clipboard Action"), style: .default, handler: { (_) in
                self.cate = ActionType.clipboard.rawValue
                cell?.detailTextLabel?.text = SwitchLanguageTool.getLocalString(of: "Clipboard Action")
                let actionCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! TextFieldCell
                actionCell.textField.isEnabled = false
                self.selectClipboardAction()
            })
            
            var isBiggerThan11: Bool
            let systemVersion = UIDevice.current.systemVersion as NSString
            isBiggerThan11 = systemVersion.floatValue >= 11.0
            
            cateSheet.addAction(cancel)
            if !isBiggerThan11 {
                cateSheet.addAction(system)
            }
            cateSheet.addAction(custom)
            cateSheet.addAction(clipboard)
            
            present(cateSheet, animated: true, completion: {
            })
        } else if indexPath.row == 2 && (tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! TextFieldCell).textField.isEnabled == false && cate == ActionType.clipboard.rawValue {
            selectClipboardAction()
        }
    }
}

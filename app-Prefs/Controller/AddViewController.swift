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
//  AddViewController.swift
//  app-Prefs
//
//  Created by 成殿 on 2017/1/20.
//  Copyright © 2017年 成璐飞. All rights reserved.
//

import UIKit
import RealmSwift

class AddViewController: UIViewController {

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-40), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.setEditing(true, animated: true)
        tableView.allowsSelectionDuringEditing = true
        return tableView
    }()
    
    lazy var footerView: UIView = {
        let footerView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 40, width: UIScreen.main.bounds.width, height: 40))
        footerView.backgroundColor = UIColor.lightGray
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        label.text = SwitchLanguageTool.getLocalString(of: "click to add a action.")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.white
        footerView.addSubview(label)
        
        footerView.addGestureRecognizer({
            let tap = UITapGestureRecognizer(target: self, action: #selector(AddViewController.footerViewTapAction(_:)))
            return tap
        }())
        
        return footerView
    }()
    
    var titleTF: UITextField?
    var actionTF: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let addBarButtonItem = UIBarButtonItem(title: SwitchLanguageTool.getLocalString(of: "AboutMe"), style: .done, target: self, action: #selector(AddViewController.rightBarButtonItemDidClicked))
        navigationItem.rightBarButtonItem = addBarButtonItem
        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        view.addSubview(footerView)
        navigationController?.navigationBar.backItem?.title = SwitchLanguageTool.getLocalString(of: "Back")
        title = SwitchLanguageTool.getLocalString(of: "Trash")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func footerViewTapAction(_ sender: AnyObject) {
        let textInputVC = TextInputViewController()
        weak var weakSelf = self
        textInputVC.actionCanBeEdit = true
        textInputVC.reloadAction = {
            weakSelf?.tableView.reloadData()
        }
        navigationController?.pushViewController(textInputVC, animated: true)
        
    }
    
    func rightBarButtonItemDidClicked() {
        
        print("present about vc")
        let aboutVC = AboutViewController()
        navigationController?.pushViewController(aboutVC, animated: true)
        
    }

}

extension AddViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        if section == 2 {
            return realm.objects(Setting.self).filter("isDeleted = true && type = '\(ActionType.system.rawValue)'").count
        } else if section == 1 {
            return realm.objects(Setting.self).filter("isDeleted = true && type = '\(ActionType.custom.rawValue)'").count
        } else if section == 0 {
            return realm.objects(Setting.self).filter("isDeleted = true && type = '\(ActionType.clipboard.rawValue)'").count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        
        let realm = try! Realm()
        
        var typeStr = ""
        switch indexPath.section {
        case 0:
            typeStr = ActionType.clipboard.rawValue
            break
        case 1:
            typeStr = ActionType.custom.rawValue
            break
        case 2:
            typeStr = ActionType.system.rawValue
            break
        default: break
        }
        
        cell!.textLabel?.text = SwitchLanguageTool.getLocalString(of: realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)'")[indexPath.row].name)
        cell!.detailTextLabel!.text = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)'")[indexPath.row].action.removingPercentEncoding!
        cell?.detailTextLabel?.adjustsFontSizeToFitWidth = true
        cell?.textLabel?.adjustsFontSizeToFitWidth = true
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var typeTitle = ""
        let realm = try! Realm()
        switch section {
        case 0:
            typeTitle = SwitchLanguageTool.getLocalString(of: "Clipboard Action")
            if realm.objects(Setting.self).filter("isDeleted = true && type = '\(ActionType.clipboard.rawValue)'").count == 0 {
                typeTitle = ""
            }
            break
        case 1:
            typeTitle = SwitchLanguageTool.getLocalString(of: "Custom Action")
            if realm.objects(Setting.self).filter("isDeleted = true && type = '\(ActionType.custom.rawValue)'").count == 0 {
                typeTitle = ""
            }
            break
        case 2:
            typeTitle = SwitchLanguageTool.getLocalString(of: "System Action")
            if realm.objects(Setting.self).filter("isDeleted = true && type = '\(ActionType.system.rawValue)'").count == 0 {
                typeTitle = ""
            }
            break
        default:
            break
        }
        return typeTitle
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .insert
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let realm = try! Realm()
        if editingStyle == .insert {
            var typeStr = ""
            switch indexPath.section {
            case 0:
                typeStr = ActionType.clipboard.rawValue
                break
            case 1:
                typeStr = ActionType.custom.rawValue
                break
            case 2:
                typeStr = ActionType.system.rawValue
                break
            default: break
            }
            try! realm.write {
                let model = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)'")[indexPath.row]
                model.sortNum = NSNumber.init(value: realm.objects(Setting.self).filter("isDeleted = false").count)
                model.isDeleted = false
                realm.add(model, update: true)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let alertSheet = UIAlertController(title: SwitchLanguageTool.getLocalString(of: "Next"), message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Cancel"), style: .cancel) { (_) in
        }
        let editAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Edit"), style: .default) { (_) in
            let realm = try! Realm()
            
            var typeStr = ""
            switch indexPath.section {
            case 0:
                typeStr = ActionType.clipboard.rawValue
                break
            case 1:
                typeStr = ActionType.custom.rawValue
                break
            case 2:
                typeStr = ActionType.system.rawValue
                break
            default: break
            }
            let TextInputVC = TextInputViewController()
            weak var weakSelf = self
            TextInputVC.reloadAction = {
                weakSelf?.tableView.reloadData()
            }
            TextInputVC.action = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)'")[indexPath.row].action
            TextInputVC.name = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)'")[indexPath.row].name
            TextInputVC.cate = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)'")[indexPath.row].type
            TextInputVC.modelIsDeleted = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)'")[indexPath.row].isDeleted
            TextInputVC.isEdit = true
            
            if typeStr == ActionType.custom.rawValue {
                TextInputVC.actionCanBeEdit = true
            }
            self.navigationController?.pushViewController(TextInputVC, animated: true)
        }
        let deleteAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Delete"), style: .destructive) { (_) in
            let realm = try! Realm()
            
            var typeStr = ""
            switch indexPath.section {
            case 0:
                typeStr = ActionType.clipboard.rawValue
                break
            case 1:
                typeStr = ActionType.custom.rawValue
                break
            case 2:
                typeStr = ActionType.system.rawValue
                break
            default: break
            }
            let model = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)'")[indexPath.row]
            try! realm.write {
                realm.delete(model)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        alertSheet.addAction(cancelAction)
        alertSheet.addAction(editAction)
        alertSheet.addAction(deleteAction)
        
        present(alertSheet, animated: true, completion: nil)
        
    }
    
}

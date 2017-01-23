//
//  ViewController.swift
//  app-Prefs
//
//  Created by 成璐飞 on 2016/12/16.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var deletedIndex = [String]()
    var sorts = [(IndexPath, IndexPath)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.allowsSelectionDuringEditing = false
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            if UserDefaults.standard.object(forKey: "isFirstOpen") as! Bool == true {
            print("this is a simulator!")
            let alertVC = UIAlertController(title: "Warning", message: "This is a simulator!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                alertVC.dismiss(animated: true, completion: nil)
            })
            alertVC.addAction(action)
            present(alertVC, animated: true, completion: {
            })
            }
        #else
        #endif
    }

    @IBAction func editAction(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        let btn = sender as! UIBarButtonItem
        
        if btn.title == NSLocalizedString("Done", comment: "") {
            for node in sorts.enumerated() {
                sortChange(by: node.element.0, to: node.element.1)
            }
            sorts = [(IndexPath, IndexPath)]()
        }
    
        btn.title = tableView.isEditing ? NSLocalizedString("Done", comment: "") : NSLocalizedString("Edit", comment: "")
        navigationItem.leftBarButtonItem?.title = tableView.isEditing ? NSLocalizedString("Cancel", comment: "") : NSLocalizedString("Add", comment: "")
        if tableView.isEditing == true {
            btn.isEnabled = false
        }
    }

    @IBAction func leftBarButtonItemAction(_ sender: Any) {
        let btn = sender as! UIBarButtonItem
        if btn.title == NSLocalizedString("Cancel", comment: "") {
            tableView.setEditing(false, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3, execute: {
                btn.title = NSLocalizedString("Add", comment: "")
                self.navigationItem.rightBarButtonItem?.title = NSLocalizedString("Edit", comment: "")
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                
                let realm = try! Realm()
                
                try! realm.write {
                    for name in self.deletedIndex {
                        let model = realm.objects(Setting.self).filter("name = '\(name)'").first
                        model!.isDeleted = false
                    }
                }
                self.deletedIndex.removeAll()
                self.tableView.reloadData()
            })
        
        } else {
            /// add
            let addVC = AddViewController()
            navigationController?.pushViewController(addVC, animated: true)
        }
    }
    
    func sortChange(by sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let realm = try! Realm()
        try! realm.write {
            let sourceModel = realm.objects(Setting.self).filter("isDeleted = false && sortNum = '\(sourceIndexPath.row)'").first!
            let destinationModel = realm.objects(Setting.self).filter("isDeleted = false && sortNum = '\(destinationIndexPath.row)'").first!
            
            let source = Int(sourceModel.sortNum)!
            let destination = Int(destinationModel.sortNum)!
            let min = source <= destination ? source : destination
            let max = source > destination ? source : destination
            var tempNum = -1
            if source > destination {
                tempNum = 1
            }
            for temp in min...max {
                
                let model = realm.objects(Setting.self).filter("sortNum = '\(temp)'").last!
                if temp == source {
                    model.sortNum = "\(destination)"
                } else {
                    model.sortNum = "\(temp + tempNum)"
                }
                realm.add(model, update: true)
                dump(model)
            }
        }
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let realm = try! Realm()
        return realm.objects(Setting.self).filter("isDeleted = false").count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        let realm = try! Realm()
        cell!.textLabel?.text = NSLocalizedString(realm.objects(Setting.self).filter("isDeleted = false && sortNum = '\(indexPath.row)'").first!.name, comment: "")
        cell!.detailTextLabel?.text = realm.objects(Setting.self).filter("isDeleted = false && sortNum = '\(indexPath.row)'").first!.action
        cell?.detailTextLabel?.adjustsFontSizeToFitWidth = true
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        print("editing")
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        navigationItem.leftBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        sortChange(by: sourceIndexPath, to: destinationIndexPath)
        sorts.append((sourceIndexPath, destinationIndexPath))
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete  {
            
            let realm = try! Realm()
            if navigationItem.rightBarButtonItem?.title != NSLocalizedString("Edit", comment: "") {
                
                self.navigationItem.rightBarButtonItem?.isEnabled = true

                deletedIndex.append(realm.objects(Setting.self).filter("isDeleted = false && sortNum = '\(indexPath.row)'").first!.name)
            } else {
                
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
            
            try! realm.write {
                let model = realm.objects(Setting.self).filter("isDeleted = false && sortNum = '\(indexPath.row)'").first!
                
                
                let num = Int(model.sortNum)
                let total = realm.objects(Setting.self).filter("isDeleted = false").count - 1
                for temp in num!...total {
                    
                    let model = realm.objects(Setting.self).filter("sortNum = '\(temp)'").first!
                    if temp == num {
                        model.sortNum = ""
                    } else {
                        model.sortNum = "\(temp - 1)"
                    }
                    dump(model)
                    realm.add(model, update: true)
                }
                model.isDeleted = true
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var action: String?
        let realm = try! Realm()
        let model = realm.objects(Setting.self).filter("isDeleted = false && sortNum = '\(indexPath.row)'").first!
        if model.type == ActionType.system.rawValue {
            action = "app-Prefs:\(model.action!)"
        } else {
            action = model.action
        }
        
        UIApplication.shared.open(URL.init(string: action!)!, options: [:]) { (ret) in
            print(ret)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let edit = UITableViewRowAction(style: .normal, title: NSLocalizedString("Edit", comment: ""), handler: { (edit, indexPath) in
            let typeVC = TypeViewController()
            weak var weakSelf = self
            typeVC.reloadAction = {
                weakSelf?.tableView.reloadData()
            }
            let realm = try! Realm()
            typeVC.action = realm.objects(Setting.self).filter("isDeleted = false && sortNum = '\(indexPath.row)'").first!.action
            typeVC.name = realm.objects(Setting.self).filter("isDeleted = false && sortNum = '\(indexPath.row)'").first!.name
            typeVC.cate = realm.objects(Setting.self).filter("isDeleted = false && sortNum = '\(indexPath.row)'").first!.type
            typeVC.isEdit = true
            self.navigationController?.pushViewController(typeVC, animated: true)
        })
        
        let delete = UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", comment: ""), handler: { (delete, indexPath) in
            self.tableView(tableView, commit: .delete, forRowAt: indexPath)
        })
        delete.backgroundColor = UIColor.red
        
        let realm = try! Realm()
        if realm.objects(Setting.self).filter("isDeleted = false && sortNum = '\(indexPath.row)'").first!.type == ActionType.custom.rawValue {
            
            
            return [delete, edit]
        } else {
            return [delete]
        }
        
        
    }
 
    
}


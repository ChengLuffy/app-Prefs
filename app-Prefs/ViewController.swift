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
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
    var displayModels = [Setting]()
    var editClicked = false
    var deleteBBI: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.backgroundColor = UIColor.init(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        
        tableView.allowsSelectionDuringEditing = false
        
        deleteBBI = UIBarButtonItem(title: NSLocalizedString("Delete", comment: ""), style: .plain, target: self, action: #selector(ViewController.deleteBBIAction(_:)))
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let realm = try! Realm()
        displayModels.removeAll()
        displayModels.append(contentsOf: realm.objects(Setting.self).filter("isDeleted = false").sorted(byKeyPath: "sortNum", ascending: true))
        for model in displayModels {
            print(model.sortNum)
        }
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
    
    func refresh() {
        displayModels.removeAll()
        let realm = try! Realm()
        displayModels.append(contentsOf: realm.objects(Setting.self).filter("isDeleted = false").sorted(byKeyPath: "sortNum", ascending: true))
        tableView.reloadData()
    }
    
    func updateSortNum() {
        
        let realm = try! Realm()
        print(displayModels)
        
        let models = realm.objects(Setting.self).filter("isDeleted = false")
        
        for node in models.enumerated() {
            if displayModels.contains(node.element) {
                try! realm.write {
                    let model = node.element
                    model.sortNum = NSNumber.init(value: displayModels.index(of: node.element)!)
                    realm.add(model, update: true)
                }
            } else {
                try! realm.write {
                    let model = node.element
                    model.isDeleted = true
                    model.sortNum = NSNumber.init(value: -1)
                    realm.add(model, update: true)
                }
            }
        }
        
        displayModels.removeAll()
        displayModels.append(contentsOf: realm.objects(Setting.self).filter("isDeleted = false").sorted(byKeyPath: "sortNum", ascending: true))
        
    }
    
    func deleteBBIAction(_ sender: Any) {
        
        let indexPaths = tableView.indexPathsForSelectedRows!.sorted(by: >)
        for indexPath in indexPaths {
            displayModels.remove(at: indexPath.row)
        }
        
        deleteBBI?.isEnabled = false
        tableView.deleteRows(at: tableView.indexPathsForSelectedRows!, with: .automatic)
    }
    
    @IBAction func editAction(_ sender: Any) {
        
        
        let btn = sender as! UIBarButtonItem
        
        if btn.title == NSLocalizedString("Done", comment: "") {
            
            updateSortNum()
            editClicked = false
            navigationItem.rightBarButtonItems = [editBarButtonItem]
            
        } else {
            editClicked = true
            deleteBBI!.isEnabled = false
            navigationItem.rightBarButtonItems = [editBarButtonItem, deleteBBI!]
        }
        tableView.setEditing(!tableView.isEditing, animated: true)
    
        btn.title = tableView.isEditing ? NSLocalizedString("Done", comment: "") : NSLocalizedString("Edit", comment: "")
        navigationItem.leftBarButtonItem?.title = tableView.isEditing ? NSLocalizedString("Cancel", comment: "") : NSLocalizedString("Add", comment: "")
        if tableView.isEditing == true {
            btn.isEnabled = false
        }
    }

    @IBAction func leftBarButtonItemAction(_ sender: Any) {
        let btn = sender as! UIBarButtonItem
        if btn.title == NSLocalizedString("Cancel", comment: "") {
            editClicked = false
            tableView.setEditing(false, animated: true)
            navigationItem.rightBarButtonItems = [editBarButtonItem]
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1, execute: {
                btn.title = NSLocalizedString("Add", comment: "")
                self.editBarButtonItem.title = NSLocalizedString("Edit", comment: "")
                self.editBarButtonItem.isEnabled = true
                
                let realm = try! Realm()
                self.displayModels.removeAll()
                self.displayModels.append(contentsOf: realm.objects(Setting.self).filter("isDeleted = false").sorted(byKeyPath: "sortNum", ascending: true))
                
                self.tableView.reloadData()
            })
        
        } else {
            /// add
            let addVC = AddViewController()
            navigationController?.pushViewController(addVC, animated: true)
        }
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return displayModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        let model = displayModels[indexPath.row]
        cell!.textLabel?.text = NSLocalizedString(model.name, comment: "")
        cell!.detailTextLabel?.text = model.action.removingPercentEncoding
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if editClicked {
            return UITableViewCellEditingStyle.init(rawValue: UITableViewCellEditingStyle.insert.rawValue | UITableViewCellEditingStyle.delete.rawValue)!
        } else {
            return .delete
        }
        
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        print("editing")
        navigationItem.leftBarButtonItem?.isEnabled = false
        editBarButtonItem.isEnabled = false
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        navigationItem.leftBarButtonItem?.isEnabled = true
        editBarButtonItem.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print(sourceIndexPath, destinationIndexPath)
        let model = displayModels[sourceIndexPath.row]
        displayModels.remove(at: sourceIndexPath.row)
        displayModels.insert(model, at: destinationIndexPath.row)
        editBarButtonItem.isEnabled = true
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete  {
//            
//            editBarButtonItemisEnabled = true
//            
//            if editBarButtonItemtitle != NSLocalizedString("Edit", comment: "") {
//                
//                displayModels.remove(at: indexPath.row)
//                updateSortNum()
//                
//            } else {
//                
//                displayModels.remove(at: indexPath.row)
//                updateSortNum()
//                
//            }
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            
//        }
//        
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !editClicked {
            var action: String?
            let realm = try! Realm()
            let model = realm.objects(Setting.self).filter("isDeleted = false && sortNum = \(indexPath.row)").first!
            if model.type == ActionType.system.rawValue {
                action = "app-\(model.action!)"
            } else {
                action = model.action
            }
            
            UIApplication.shared.open(URL.init(string: action!)!, options: [:]) { (ret) in
                if ret == false {

                    let alert = UIAlertController(title: NSLocalizedString("Failed to open", comment: ""), message: NSLocalizedString("Please check the settings of ", comment: "") + model.name, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (_) in
                        tableView.deselectRow(at: indexPath, animated: true)
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    tableView.deselectRow(at: indexPath, animated: true)
                }
                
            }
            

        } else {
            
            deleteBBI?.isEnabled = true
            editBarButtonItem.isEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.indexPathsForSelectedRows?.count == nil {
            deleteBBI?.isEnabled = false
        } else {
            deleteBBI?.isEnabled = true
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
            typeVC.action = realm.objects(Setting.self).filter("isDeleted = false && sortNum = \(indexPath.row)").first!.action
            typeVC.name = realm.objects(Setting.self).filter("isDeleted = false && sortNum = \(indexPath.row)").first!.name
            typeVC.cate = realm.objects(Setting.self).filter("isDeleted = false && sortNum = \(indexPath.row)").first!.type
            typeVC.modelIsDeleted = realm.objects(Setting.self).filter("isDeleted = false && sortNum = \(indexPath.row)").first!.isDeleted
            typeVC.isEdit = true
            typeVC.sortNum = realm.objects(Setting.self).filter("isDeleted = false && sortNum = \(indexPath.row)").first!.sortNum
            self.navigationController?.pushViewController(typeVC, animated: true)
        })
        edit.backgroundColor = UIColor.darkGray
        
        let copy = UITableViewRowAction(style: .normal, title: NSLocalizedString("Copy", comment: "")) { (_, indexPath) in
            let cell = tableView.cellForRow(at: indexPath)
            let action = cell!.detailTextLabel!.text
            
            let pboard = UIPasteboard.general
            pboard.string = action
            let alertVC = UIAlertController.init(title: NSLocalizedString("action has been copied", comment: ""), message: "", preferredStyle: .alert)
            weak var weakSelf = self
            self.present(alertVC, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    weakSelf!.dismiss(animated: true, completion: {
                    })
                })
            }
        }
        
        let delete = UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", comment: ""), handler: { (delete, indexPath) in
            self.displayModels.remove(at: indexPath.row)
            self.updateSortNum()
            self.editBarButtonItem.isEnabled = true
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        })
        delete.backgroundColor = UIColor.red
        
        let realm = try! Realm()
        if realm.objects(Setting.self).filter("isDeleted = false && sortNum = \(indexPath.row)").first!.type == ActionType.custom.rawValue {
            
            return [delete, edit, copy]
        } else {
            return [delete, copy]
        }
    }
 
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
}


//
//  ViewController.swift
//  app-Prefs
//
//  Created by 成璐飞 on 2016/12/16.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

//    @IBOutlet weak var alertLable: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var keys: NSMutableArray?
    var deletedKeys = [String]()
    let actionPrefsDirct = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Settings", ofType: ".plist")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelectionDuringEditing = false
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.app-Prefs")
        keys = NSMutableArray(contentsOf: (path?.appendingPathComponent("Setting.plist"))!)
        
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
            let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.app-Prefs")
            if keys?.write(to: (path?.appendingPathComponent("Setting.plist"))!, atomically: true) == false {
                print("array write failed")
            }
            
            var oldDeletedKeys = NSMutableArray(contentsOf: path!.appendingPathComponent("Deleted.plits"))
            if oldDeletedKeys == nil {
                oldDeletedKeys = NSMutableArray(array: deletedKeys)
            } else {
                oldDeletedKeys!.addObjects(from: deletedKeys)
            }
            
            oldDeletedKeys?.write(to: path!.appendingPathComponent("Deleted.plist"), atomically: true)
            
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
                self.deletedKeys = [String]()
                btn.title = NSLocalizedString("Add", comment: "")
                self.navigationItem.rightBarButtonItem?.title = NSLocalizedString("Edit", comment: "")
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.app-Prefs")
                self.keys = NSMutableArray(contentsOf: (path?.appendingPathComponent("Setting.plist"))!)
            })
            
        } else {
            /// add
            let addVC = AddViewController()
            navigationController?.pushViewController(addVC, animated: true)
        }
    }
//    func createAlertAction(by titleAction: (title: String, action: String)) -> UIAlertAction! {
//        let action = UIAlertAction(title: NSLocalizedString(titleAction.title, comment: ""), style: .default) { (_) in
//            UIApplication.shared.open(URL.init(string: "app-Prefs:\(self.actionPrefsDirct?[titleAction.title]!)")!, options: [:], completionHandler: { (_) in
//            })
//        }
//        return action
//    }
//    
//    @IBAction func btnDidClicked(_ sender: Any) {
//        
//        let alertSheet = UIAlertController.init(title: NSLocalizedString("Next", comment: ""), message: "", preferredStyle: .actionSheet)
//        
//        for (title, prfs) in actionPrefsDirct! {
//            let action = createAlertAction(by: (title as! String, prfs as! String))
//            alertSheet.addAction(action!)
//        }
//        
//        let cancel = UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (_) in
//        }
//        alertSheet.addAction(cancel)
//        
//        present(alertSheet, animated: true) {
//        }
//        
//    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return keys!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        cell!.textLabel?.text = NSLocalizedString((keys![indexPath.row] as! String), comment: "")
        cell!.detailTextLabel?.text = actionPrefsDirct?.object(forKey: keys![indexPath.row] as! String) as! String?
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
//        keys?.exchangeObject(at: sourceIndexPath.row, withObjectAt: destinationIndexPath.row)
        var sourceIndex = sourceIndexPath.row
        let destinationIndex = destinationIndexPath.row
        if sourceIndex < destinationIndex {
            for index in sourceIndex...destinationIndex {
                keys!.exchangeObject(at: sourceIndex, withObjectAt: index)
                sourceIndex = index
            }
        } else if sourceIndex > destinationIndex {
            for _ in 1...(sourceIndex - destinationIndex) {
                keys!.exchangeObject(at: sourceIndex, withObjectAt: sourceIndex - 1)
                sourceIndex = sourceIndex - 1
            }
        } else {
            
        }
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if navigationItem.rightBarButtonItem?.title == NSLocalizedString("Edit", comment: "") {
                let alertVC = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Delete", comment: "") + "'" + NSLocalizedString((keys![indexPath.row] as! String) ,comment: "") + "'", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (_) in
                    tableView.setEditing(false, animated: false)
                })
                let sureAction = UIAlertAction(title: NSLocalizedString("Sure", comment: ""), style: .default, handler: { (_) in
                    self.deletedKeys.append(self.keys?[indexPath.row] as! String)
                    self.keys?.removeObject(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.app-Prefs")
                    if self.keys?.write(to: (path?.appendingPathComponent("Setting.plist"))!, atomically: true) == false {
                        print("array write failed")
                    }
                    var oldDeletedKeys = NSMutableArray(contentsOf: path!.appendingPathComponent("deleted.plits"))
                    if oldDeletedKeys == nil {
                        oldDeletedKeys = NSMutableArray(array: self.deletedKeys)
                    } else {
                        oldDeletedKeys!.addObjects(from: self.deletedKeys)
                    }
                    oldDeletedKeys?.write(to: path!.appendingPathComponent("Deleted.plist"), atomically: true)
                    
                })
                alertVC.addAction(cancelAction)
                alertVC.addAction(sureAction)
                present(alertVC, animated: true, completion: {
                })
            } else {
                deletedKeys.append(keys?[indexPath.row] as! String)
                keys?.removeObject(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        UIApplication.shared.open(URL.init(string: "app-Prefs:\(actionPrefsDirct?.object(forKey: keys![indexPath.row]))")!, options: [:]) { (ret) in
//        }
        UIApplication.shared.open(URL.init(string: "app-Prefs:\(self.actionPrefsDirct?.object(forKey: keys?[indexPath.row] as! String))")!, options: [:], completionHandler: { (_) in
        })
    }
    /**
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let cancelAction = UITableViewRowAction(style: .default, title: "Cancel") { (action, indexP) in
//            tableView.setEditing(false, animated: false)
            tableView.endEditing(false)
            action.
        }
        cancelAction.backgroundColor = UIColor.lightGray
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexP) in
            self.deletedKeys.append(self.keys?[indexPath.row] as! String)
            self.keys?.removeObject(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.app-Prefs")
            if self.keys?.write(to: (path?.appendingPathComponent("Setting.plist"))!, atomically: true) == false {
                print("array write failed")
            }
            var oldDeletedKeys = NSMutableArray(contentsOf: path!.appendingPathComponent("deleted.plits"))
            if oldDeletedKeys == nil {
                oldDeletedKeys = NSMutableArray(array: self.deletedKeys)
            } else {
                oldDeletedKeys!.addObjects(from: self.deletedKeys)
            }
        }
        deleteAction.backgroundColor = UIColor.red
        return [deleteAction, cancelAction]
    }
 */
    
}


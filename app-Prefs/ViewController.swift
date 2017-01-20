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
        #if (arch(i386) || arch(x86_64)) && os(iOS)
//            alertLable.isHidden = false
            print("this is a simulator!")
        #else
//            alertLable.isHidden = true
        #endif
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.app-Prefs")
        keys = NSMutableArray(contentsOf: (path?.appendingPathComponent("Setting.plist"))!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func editAction(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        let btn = sender as! UIBarButtonItem
        
        if btn.title == NSLocalizedString("Done", comment: "") {
            let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.app-Prefs")
            if keys?.write(to: (path?.appendingPathComponent("Setting.plist"))!, atomically: true) == false {
                print("array write failed")
            }
            
            var oldDeletedKeys = NSMutableArray(contentsOf: path!.appendingPathComponent("deleted.plits"))
            if oldDeletedKeys == nil {
                oldDeletedKeys = NSMutableArray(array: deletedKeys)
            } else {
                oldDeletedKeys!.addObjects(from: deletedKeys)
            }
            
        }
        
        btn.title = tableView.isEditing ? NSLocalizedString("Done", comment: "") : NSLocalizedString("Edit", comment: "")
        navigationItem.leftBarButtonItem?.title = tableView.isEditing ? NSLocalizedString("Cancel", comment: "") : NSLocalizedString("Add", comment: "")
    }

    @IBAction func leftBarButtonItemAction(_ sender: Any) {
        let btn = sender as! UIBarButtonItem
        if btn.title == NSLocalizedString("Cancel", comment: "") {
            tableView.setEditing(false, animated: true)
            deletedKeys = [String]()
            btn.title = NSLocalizedString("Add", comment: "")
        } else {
            /// add
            print(deletedKeys)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = NSLocalizedString((keys![indexPath.row] as! String), comment: "")
        return cell
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
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        keys?.exchangeObject(at: sourceIndexPath.row, withObjectAt: destinationIndexPath.row)
        var sourceIndex = sourceIndexPath.row
        let destinationIndex = destinationIndexPath.row
        if sourceIndex < destinationIndex {
            for index in sourceIndex...destinationIndex {
                keys!.exchangeObject(at: sourceIndex, withObjectAt: index)
                sourceIndex = index
            }
        } else {
            for _ in 1...(sourceIndex - destinationIndex) {
                keys!.exchangeObject(at: sourceIndex, withObjectAt: sourceIndex - 1)
                sourceIndex = sourceIndex - 1
            }

        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletedKeys.append(keys?[indexPath.row] as! String)
            keys?.removeObject(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    
}


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

class AddViewController: UIViewController {

    lazy var tableView: UITableView = {
        let tabelView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: .plain)
        tabelView.delegate = self
        tabelView.dataSource = self
//        tabelView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tabelView.setEditing(true, animated: true)
        tabelView.allowsMultipleSelectionDuringEditing = true
        return tabelView
    }()
    
    var keys: NSMutableArray?
    let actionPrefsDirct = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Settings", ofType: ".plist")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let addBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Add", comment: ""), style: .done, target: self, action: #selector(AddViewController.addBarButtonItemDidClicked))
        navigationItem.rightBarButtonItem = addBarButtonItem
        // Do any additional setup after loading the view.
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.app-Prefs")?.appendingPathComponent("Deleted.plist")
        keys = NSMutableArray(contentsOf: path!)
        if keys?.count == 0 || keys == nil {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
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
    
    func addBarButtonItemDidClicked() {
        print("done")
        // delete those in Deleted.plist
        // add those to Setting.plist
        // delete rows in tableView
        // add rows in ViewController's tableView
        
        let indexPaths: [IndexPath] = tableView.indexPathsForSelectedRows ?? [IndexPath]()
        
        let settingPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.app-Prefs")?.appendingPathComponent("Setting.plist")
        let deletedPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.app-Prefs")?.appendingPathComponent("Deleted.plist")
        let settings = NSMutableArray(contentsOf: settingPath!)
        
//        for indexPath in indexPaths {
//            settings?.add(keys![indexPath.row])
//        }
//        
//        for IndexPath in indexPaths {
//            let key = keys?[IndexPath.row]
//            keys?.remove(key!)
//        }
        
        let tempDeleted = NSMutableArray(array: keys!)
        for indexPath in indexPaths {
            let key = tempDeleted[indexPath.row]
            settings?.add(key)
            keys?.remove(key)
        }
        
        settings?.write(to: settingPath!, atomically: true)
        keys?.write(to: deletedPath!, atomically: true)
        
        tableView.reloadData()
        for vc in (navigationController?.viewControllers)! {
            if vc.isKind(of: ViewController.self) {
                let viewControlller = vc as! ViewController
                viewControlller.keys = NSMutableArray(contentsOf: settingPath!)
                viewControlller.tableView.reloadData()
            }
        }
        
    }

}

extension AddViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        cell!.textLabel?.text = NSLocalizedString(keys?[indexPath.row] as! String, comment: "")
        cell!.detailTextLabel!.text = actionPrefsDirct!.object(forKey: keys![indexPath.row] as! String) as? String
        
        return cell!
    }
}

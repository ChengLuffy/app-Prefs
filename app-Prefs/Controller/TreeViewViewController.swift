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
//  TreeViewViewController.swift
//  JSONTreeView
//
//  Created by 成殿 on 2017/2/23.
//  Copyright © 2017年 成殿. All rights reserved.
//

import UIKit

class TreeViewViewController: UIViewController {
    
    var dataSource: AnyHashable?

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        
        let pathBBI = UIBarButtonItem(title: SwitchLanguageTool.getLocalString(of: "Path"), style: .done, target: self, action: #selector(TreeViewViewController.getFullPath))
        navigationItem.rightBarButtonItem = pathBBI
        
        view.addSubview(tableView)
    }
    
    func getFullPath() {
        var path = ""
        for vc in (navigationController?.viewControllers)! {
            if vc.isKind(of: TreeViewViewController.self) {
                path = path + "/" + vc.title!
            }
        }
        let alertC = UIAlertController(title: SwitchLanguageTool.getLocalString(of: "Path"), message: path, preferredStyle: .alert)
        let copyAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Copy"), style: .destructive, handler: { (_) in
            let pasteboard = UIPasteboard.general
            pasteboard.string = alertC.message!
        })
        let cancelAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Cancel"), style: .cancel, handler: { (_) in
        })
        
        alertC.addAction(copyAction)
        alertC.addAction(cancelAction)
        
        present(alertC, animated: true) {
        }
        
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

extension TreeViewViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dict = dataSource as? Dictionary<String, Any> else {
            guard let arr = dataSource as? Array<Any> else {
                return 1
            }
            return arr.count
        }
        return dict.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        }
        
        guard let dict = dataSource as? Dictionary<String, Any> else {
            guard (dataSource as? Array<Any>) != nil else {
                cell?.textLabel?.text = "\(dataSource!)"
                cell?.detailTextLabel?.text = ""
                return cell!
            }
            cell?.textLabel?.text = "\(indexPath.row)"
            cell?.detailTextLabel?.text = getIndexType(of: indexPath.row)
            return cell!
        }
        cell?.textLabel?.text = Array(dict.keys)[indexPath.row]
        cell?.detailTextLabel?.text = getValueType(of: (cell?.textLabel?.text!)!)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let dict = dataSource as? Dictionary<String, Any> else {
            guard let arr = dataSource as? Array<AnyHashable> else {
                let alertC = UIAlertController(title: SwitchLanguageTool.getLocalString(of: "Detail"), message: tableView.cellForRow(at: indexPath)?.textLabel?.text, preferredStyle: .alert)
                let copyAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Copy"), style: .destructive, handler: { (_) in
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = alertC.message!
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                })
                
                alertC.addAction(copyAction)
                alertC.addAction(cancelAction)
                
                present(alertC, animated: true, completion: {
                })
                return
            }
            let treeVC = TreeViewViewController()
            treeVC.title = "\(indexPath.row)"
            treeVC.dataSource = arr[indexPath.row]
            navigationController?.pushViewController(treeVC, animated: true)
            return
        }
        let treeVC = TreeViewViewController()
        treeVC.title = "\(Array(dict.keys)[indexPath.row])"
        treeVC.dataSource = dict[Array(dict.keys)[indexPath.row]] as! AnyHashable?
        navigationController?.pushViewController(treeVC, animated: true)
    }
    
    func getValueType(of key: String) -> String? {
        guard let dict = dataSource as? Dictionary<String, Any> else {
            return nil
        }
        if ((dict[key] as? Dictionary<String, Any>) != nil) {
            return "Dictionary"
        } else if ((dict[key] as? Array<Any>) != nil) {
            return "Array"
        } else {
            return "\(dict[key]!)"
        }
    
    }
    
    func getIndexType(of index: Int) -> String? {
        guard let arr = dataSource as? Array<Any> else {
            return nil
        }
        
        if (arr[index] as? Dictionary<String, Any>) != nil {
            return "Dictionary"
        } else if (arr[index] as? Array< Any>) != nil {
            return "Array"
        } else {
            return "\(arr[index])"
        }
    }
}

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
//  TextViewController.swift
//  app-Prefs
//
//  Created by 成殿 on 2017/2/23.
//  Copyright © 2017年 成璐飞. All rights reserved.
//

import UIKit
import SVProgressHUD

class TextViewController: UIViewController {

    var urlStr: URL?
    var textView: UITextView?
    var dataSource: AnyHashable?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        title = "TextView"
        
        let formatBBI = UIBarButtonItem(title: SwitchLanguageTool.getLocalString(of: "Format"), style: .done, target: self, action: #selector(TextViewController.format))
        formatBBI.isEnabled = false
        navigationItem.rightBarButtonItem = formatBBI
        
        textView = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        textView?.isEditable = false
        self.view.addSubview(self.textView!)
        // Do any additional setup after loading the view.
    }

    func format() {
        
        let treeViewC = TreeViewViewController()
        treeViewC.dataSource = dataSource
        treeViewC.title = "DataSource"
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(treeViewC, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SVProgressHUD.show()
        let index = urlStr?.absoluteString.index((urlStr?.absoluteString.startIndex)!, offsetBy: 15)
        let str = urlStr?.absoluteString.substring(from: index!).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        guard str != "" || str != nil else {
            SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "jsonUrlError"))
            SVProgressHUD.dismiss(withDelay: 1, completion: {
                let _ = self.navigationController?.popViewController(animated: true)
            })
            return
        }
        let url = URL.init(string: str!)
        guard url != nil else {
            SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "jsonUrlError"))
            SVProgressHUD.dismiss(withDelay: 1, completion: {
                let _ = self.navigationController?.popViewController(animated: true)
            })
            return
        }
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession.init(configuration: sessionConfig)
        let dataTask = session.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error == nil {
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    print(json)
                    DispatchQueue.main.async {
                        self.dataSource = json as? AnyHashable
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        self.textView?.text = (json as! Dictionary<String, Any>).description.removingPercentEncoding!
                        SVProgressHUD.dismiss()
                    }
                } catch _ {
                    SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "NotJSONData"))
                    DispatchQueue.main.async {
                        self.textView?.text = String.init(data: data!, encoding: .utf8)
                    }
                }
                
            } else {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                SVProgressHUD.dismiss(withDelay: 1, completion: {
                    let _ = self.navigationController?.popViewController(animated: true)
                })
            }
        })
        dataTask.resume()
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

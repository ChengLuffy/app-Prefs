//
//  ViewController.swift
//  app-Prefs
//
//  Created by 成璐飞 on 2016/12/16.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let actionPrefsDirct = ["电池": "root=BATTERY_USAGE",
                            "通用设置": "root=General",
                            "剩余空间": "root=General&path=STORAGE_ICLOUD_USAGE/DEVICE_STORAGE",
                            "蜂窝数据": "root=MOBILE_DATA_SETTINGS_ID",
                            "无线设置": "root=WIFI",
                            "蓝牙": "root=Bluetooth",
                            "定位": "root=Privacy&path=LOCATION",
                            "辅助功能": "root=General&path=ACCESSIBILITY",
                            "关于手机": "root=General&path=About",
                            "键盘": "root=General&path=Keyboard",
                            "显示": "root=DISPLAY",
                            "声音": "root=Sounds",
                            "应用商店设置": "root=STORE",
                            "壁纸": "root=Wallpaper"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createAlertAction(by titleAction: (title: String, action: String)) -> UIAlertAction! {
        let action = UIAlertAction(title: titleAction.title, style: .default) { (_) in
            UIApplication.shared.open(URL.init(string: "app-Prefs:\(self.actionPrefsDirct[titleAction.title]!)")!, options: [:], completionHandler: { (_) in
            })
        }
        return action
    }
    
    @IBAction func btnDidClicked(_ sender: Any) {
        
        let alertSheet = UIAlertController.init(title: "选择下一步", message: "", preferredStyle: .actionSheet)
        
        for (title, prfs) in actionPrefsDirct {
            print(title, prfs)
            let action = createAlertAction(by: (title, prfs))
            alertSheet.addAction(action!)
        }
        
        let cancel = UIAlertAction.init(title: "取消", style: .cancel) { (_) in
        }
        alertSheet.addAction(cancel)
        
        present(alertSheet, animated: true) {
        }
        
    }

}


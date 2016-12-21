//
//  ViewController.swift
//  app-Prefs
//
//  Created by 成璐飞 on 2016/12/16.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let actionPrefsDirct = [NSLocalizedString("Battery", comment: ""): "root=BATTERY_USAGE",
                            NSLocalizedString("General", comment: ""): "root=General",
                            NSLocalizedString("Storage", comment: ""): "root=General&path=STORAGE_ICLOUD_USAGE/DEVICE_STORAGE",
                            NSLocalizedString("Date", comment: ""): "root=MOBILE_DATA_SETTINGS_ID",
                            NSLocalizedString("WLAN", comment: ""): "root=WIFI",
                            NSLocalizedString("Bluetooth", comment: ""): "root=Bluetooth",
                            NSLocalizedString("Location", comment: ""): "root=Privacy&path=LOCATION",
                            NSLocalizedString("Accessibility", comment: ""): "root=General&path=ACCESSIBILITY",
                            NSLocalizedString("About", comment: ""): "root=General&path=About",
                            NSLocalizedString("Keyboards", comment: ""): "root=General&path=Keyboard",
                            NSLocalizedString("Display", comment: ""): "root=DISPLAY",
                            NSLocalizedString("Sounds", comment: ""): "root=Sounds",
                            NSLocalizedString("Stores", comment: ""): "root=STORE",
                            NSLocalizedString("Wallpaper", comment: ""): "root=Wallpaper",
                            NSLocalizedString("iCloud", comment: ""): "root=CASTLE",
                            NSLocalizedString("iCloudStorage", comment: ""): "root=CASTLE&path=STORAGE_AND_BACKUP",
                            NSLocalizedString("Hotspot", comment: ""): "root=INTERNET_TETHERING",
                            NSLocalizedString("VPN", comment: ""): "root=General&path=VPN",
                            NSLocalizedString("Update", comment: ""): "root=General&path=SOFTWARE_UPDATE_LINK",
                            NSLocalizedString("Profiles", comment: ""): "root=General&path=ManagedConfigurationList",
                            NSLocalizedString("Reset", comment: ""): "root=General&path=Reset",
                            NSLocalizedString("Photos", comment: ""): "root=Photos",
                            NSLocalizedString("Phone", comment: ""): "root=Phone",
                            NSLocalizedString("Notifications", comment: ""): "root=NOTIFICATIONS_ID",
                            NSLocalizedString("Notes", comment: ""): "root=NOTES",
                            NSLocalizedString("Music", comment: ""): "root=MUSIC",
                            NSLocalizedString("Language", comment: ""): "root=General&path=INTERNATIONAL",
                            NSLocalizedString("Data", comment: ""): "root=General&path=DATE_AND_TIME"]
    
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
        
        let alertSheet = UIAlertController.init(title: NSLocalizedString("Next", comment: ""), message: "", preferredStyle: .actionSheet)
        
        for (title, prfs) in actionPrefsDirct {
            let action = createAlertAction(by: (title, prfs))
            alertSheet.addAction(action!)
        }
        
        let cancel = UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (_) in
        }
        alertSheet.addAction(cancel)
        
        present(alertSheet, animated: true) {
        }
        
    }

}


//
//  ViewController.swift
//  app-Prefs
//
//  Created by 成璐飞 on 2016/12/16.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var alertLable: UILabel!
    let actionPrefsDirct = ["Battery": "root=BATTERY_USAGE",
                            "General": "root=General",
                            "Storage": "root=General&path=STORAGE_ICLOUD_USAGE/DEVICE_STORAGE",
                            "Data": "root=MOBILE_DATA_SETTINGS_ID",
                            "WLAN": "root=WIFI",
                            "Bluetooth": "root=Bluetooth",
                            "Location": "root=Privacy&path=LOCATION",
                            "Accessibility": "root=General&path=ACCESSIBILITY",
                            "About": "root=General&path=About",
                            "Keyboards": "root=General&path=Keyboard",
                            "Display": "root=DISPLAY",
                            "Sounds": "root=Sounds",
                            "Stores": "root=STORE",
                            "Wallpaper": "root=Wallpaper",
                            "iCloud": "root=CASTLE",
                            "iCloudStorage": "root=CASTLE&path=STORAGE_AND_BACKUP",
                            "Hotspot": "root=INTERNET_TETHERING",
                            "VPN": "root=General&path=VPN",
                            "Update": "root=General&path=SOFTWARE_UPDATE_LINK",
                            "Profiles": "root=General&path=ManagedConfigurationList",
                            "Reset": "root=General&path=Reset",
                            "Photos": "root=Photos",
                            "Phone": "root=Phone",
                            "Notifications": "root=NOTIFICATIONS_ID",
                            "Notes": "root=NOTES",
                            "Music": "root=MUSIC",
                            "Language": "root=General&path=INTERNATIONAL",
                            "Date": "root=General&path=DATE_AND_TIME"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            alertLable.isHidden = false
        #else
            alertLable.isHidden = true
        #endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createAlertAction(by titleAction: (title: String, action: String)) -> UIAlertAction! {
        let action = UIAlertAction(title: NSLocalizedString(titleAction.title, comment: ""), style: .default) { (_) in
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


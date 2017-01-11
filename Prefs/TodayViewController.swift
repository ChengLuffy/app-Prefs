//
//  TodayViewController.swift
//  Prefs
//
//  Created by 成璐飞 on 2016/12/20.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    
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
    
    lazy var collectionView: UICollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width - 60)/3, height: 40)
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(UINib.init(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        return collectionView
        
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        preferredContentSize = CGSize(width: UIScreen.main.bounds.size.width-16, height: 200)
        view.addSubview(collectionView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            preferredContentSize = CGSize(width: maxSize.width, height: 200)
            collectionView.frame.size = CGSize(width: maxSize.width, height: 200)
        } else {
            preferredContentSize = CGSize(width: maxSize.width, height: 480)
            collectionView.frame.size = CGSize(width: maxSize.width, height: 480)
        }
        
        print(maxSize)
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}

extension TodayViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 27
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.label.text = NSLocalizedString(Array(actionPrefsDirct.keys)[indexPath.row], comment: "")
        cell.prefs = actionPrefsDirct[Array(actionPrefsDirct.keys)[indexPath.row]]
        cell.contentView.backgroundColor = UIColor.init(white: 1, alpha: 0.3)
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.clipsToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        // Array(actionPrefsDirct.values)[indexPath.row]
        extensionContext?.open(URL.init(string: "Prefs:\(cell.prefs!)")!, completionHandler: { (_) in
        })
    }
}

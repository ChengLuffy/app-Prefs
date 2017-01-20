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
    
    
    let actionPrefsDirct = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Settings", ofType: ".plist")!)
    var keys: NSMutableArray?
    
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
        
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.app-Prefs")
        keys = NSMutableArray(contentsOf: (path?.appendingPathComponent("Setting.plist"))!)
        if keys == nil {
            keys = NSMutableArray(array: (actionPrefsDirct?.allKeys)!)
        }
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
            preferredContentSize = CGSize(width: maxSize.width, height: CGFloat(60+50*((keys?.count)!/3)))
            collectionView.frame.size = CGSize(width: maxSize.width, height: CGFloat(60+50*((keys?.count)!/3)))
            
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
        return keys!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.label.text = NSLocalizedString(keys![indexPath.row] as! String, comment: "")
        cell.prefs = actionPrefsDirct?.object(forKey: keys![indexPath.row] as! String) as! String!
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

//
//  TodayViewController.swift
//  Prefs
//
//  Created by 成璐飞 on 2016/12/20.
//  Copyright © 2016年 成璐飞. All rights reserved.
//
import UIKit
import NotificationCenter
import RealmSwift

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var realm: Realm?
    
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
        
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.chengluffy.app-Prefs")
        let realmURL = container!.appendingPathComponent("defualt.realm")
        
        Realm.Configuration.defaultConfiguration.fileURL = realmURL
        realm = try! Realm()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            var height: CGFloat?
            if (realm?.objects(Setting.self).filter("isDeleted = false").count)! > 3 {
                height = 200
            } else {
                height = 100
            }
            preferredContentSize = CGSize(width: maxSize.width, height: 200)
            collectionView.frame.size = CGSize(width: maxSize.width, height: height!)
        } else {
            var height: CGFloat?
            if (realm?.objects(Setting.self).filter("isDeleted = false").count)! > 3 {
                height = CGFloat(60+50*((realm!.objects(Setting.self).filter("isDeleted = false").count - 1)/3))
            } else {
                height = 200
            }
            preferredContentSize = CGSize(width: maxSize.width, height: height!)
            collectionView.frame.size = CGSize(width: maxSize.width, height: height!)
            
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
        return realm!.objects(Setting.self).filter("isDeleted = false").count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.label.text = NSLocalizedString(realm!.objects(Setting.self).filter("isDeleted = false && sortNum = \(indexPath.row)").first!.name, comment: "")
        cell.prefs = realm!.objects(Setting.self).filter("isDeleted = false && sortNum = \(indexPath.row)").first!.action!
        cell.contentView.backgroundColor = UIColor.init(white: 1, alpha: 0.3)
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.clipsToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        
        var action: String
        let model = realm!.objects(Setting.self).filter("isDeleted = false && sortNum = \(indexPath.row)").first!
        if model.type == ActionType.system.rawValue {
            action = "Prefs:\(model.action!)"
        } else {
            action = model.action
        }
        
        extensionContext?.open(URL.init(string: action)!, completionHandler: { (ret) in
            print(ret)
            if ret == false {
                let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
                let tempStr = cell.label.text!
                cell.contentView.layer.borderWidth = 1
                cell.contentView.layer.borderColor = UIColor.red.cgColor
                cell.label.text = "Errors"
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5, execute: { 
                    cell.contentView.layer.borderWidth = 0
                    cell.contentView.layer.borderColor = UIColor.white.cgColor
                    cell.label.text = NSLocalizedString(tempStr, comment: "")
                })
            }
        })
        
    }
}

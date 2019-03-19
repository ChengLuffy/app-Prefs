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
import AudioToolbox

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var realm: Realm?
    
//    let width: Float = (view.frame.size.width-40)/3
    let width: CGFloat = 105 - (375 - (UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height ? UIScreen.main.bounds.size.height : UIScreen.main.bounds.size.width))/3
    
    lazy var collectionView: UICollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: width, height: 40)
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowLayout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(UINib.init(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        return collectionView
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        preferredContentSize = CGSize(width: view.frame.size.width, height: 110)
        view.addSubview(collectionView)
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.chengluffy.app-Prefs")
        let realmURL = container!.appendingPathComponent("defualt.realm")
        
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        Realm.Configuration.defaultConfiguration.fileURL = realmURL
        realm = try! Realm()
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.itemSize = CGSize(width: (view.frame.size.width-40)/3, height:layout.itemSize.height)
//        layout.minimumLineSpacing = 10
//    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["collectionView": collectionView]
        let hc = NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: views)
        let vc = NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil, views: views)
        
        view.addConstraints(hc)
        view.addConstraints(vc)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            preferredContentSize = maxSize
            collectionView.frame.size = maxSize
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: width, height:maxSize.height/11*4)
            print(maxSize.height/11*4)
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.minimumLineSpacing = 10
        } else {
            var height: CGFloat?
            if (realm?.objects(Setting.self).filter("isDeleted = false").count)! > 3 {
                let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
                let temp = layout.itemSize.height / 4
                print(temp)
                let lines: Int = (realm!.objects(Setting.self).filter("isDeleted = false").count - 1)/3
                height = CGFloat(temp*6 + (temp * 5 * CGFloat(lines)))
            } else {
                height = 110
            }
            height = maxSize.height > height! ? height! : maxSize.height
            print(height ?? "nil")
            collectionView.frame.size = CGSize(width: maxSize.width, height: height!)
            preferredContentSize = CGSize(width: maxSize.width, height: height!)
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
        cell.label.text = SwitchLanguageTool.getLocalString(of: realm!.objects(Setting.self).filter("isDeleted = false && sortNum = \(indexPath.row)").first!.name)
        cell.prefs = realm!.objects(Setting.self).filter("isDeleted = false && sortNum = \(indexPath.row)").first!.action!
        cell.contentView.backgroundColor = UIColor.init(white: 1, alpha: 0.3)
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.clipsToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        if UserDefaults.init(suiteName: "group.chengluffy.app-Prefs")?.value(forKey: "shock") == nil || UserDefaults.init(suiteName: "group.chengluffy.app-Prefs")?.value(forKey: "shock") as! Bool == true {
            if (self.traitCollection.forceTouchCapability == .available) {
                // 1519 1520
//                AudioServicesPlaySystemSound(1520)
                let feedback = UIImpactFeedbackGenerator(style: .light)
                feedback.prepare()
                feedback.impactOccurred()
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
            
        }
        var action: String = ""
        let model = realm!.objects(Setting.self).filter("isDeleted = false && sortNum = \(indexPath.row)").first!
        if model.type == ActionType.clipboard.rawValue {
            action = ClipboardActionTool.performAction(model.action)
        } else {
            action = model.action
            if action.contains("[clipboard]") {
                let paste = UIPasteboard.general
                action = action.components(separatedBy: "[clipboard]").joined(separator: paste.string ?? "")
            }
        }
        
        guard action != "" else {
            return
        }
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.layer.borderWidth = 1
        cell?.contentView.layer.borderColor = UIColor.cyan.cgColor
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.25, execute: {
            cell?.contentView.layer.borderWidth = 0
            cell?.contentView.layer.borderColor = UIColor.white.cgColor
        })

        extensionContext?.open(URL.init(string: action)!, completionHandler: { (ret) in
            print(ret)
            if ret == false {
                print(action)
                self.showError(in: indexPath)
            }
        })
        
    }
    
    func showError(in indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        let tempStr = cell.label.text!
        cell.contentView.layer.borderWidth = 1
        cell.contentView.layer.borderColor = UIColor.red.cgColor
        cell.label.text = "Errors"
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5, execute: {
            cell.contentView.layer.borderWidth = 0
            cell.contentView.layer.borderColor = UIColor.white.cgColor
            cell.label.text = SwitchLanguageTool.getLocalString(of: tempStr)
        })
    }
}

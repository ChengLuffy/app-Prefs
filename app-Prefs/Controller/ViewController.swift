//
//  ViewController.swift
//  app-Prefs
//
//  Created by 成璐飞 on 2016/12/16.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD

enum DisplayModel {
    case display
    case cache
}

class ViewController: UIViewController {

    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    lazy var isBiggerThan11: Bool = {
        var isBiggerThan11: Bool
        let systemVersion = UIDevice.current.systemVersion as NSString
        isBiggerThan11 = systemVersion.floatValue >= 11.0
        return isBiggerThan11
    }()
    lazy var settingBBI: UIBarButtonItem = {
        let settingBBI = UIBarButtonItem(image: #imageLiteral(resourceName: "Setting"), style: .plain, target: self, action: #selector(ViewController.settingBBIDidSelected(_:)))
        settingBBI.width = 20
        return settingBBI
    }()
    lazy var editBBI: UIBarButtonItem = {
        let editBBI = UIBarButtonItem(image: #imageLiteral(resourceName: "Edit"), style: .plain, target: self, action: #selector(ViewController.editAction(_:)))
        editBBI.width = 20
        return editBBI
    }()
    lazy var deleteBBI: UIBarButtonItem = {
        let deleteBBI = UIBarButtonItem(image: #imageLiteral(resourceName: "Delete"), style: .plain, target: self, action: #selector(ViewController.deleteBBIAction(_:)))
        deleteBBI.width = 20
        return deleteBBI
    }()
    lazy var cancelBBI: UIBarButtonItem = {
        let cancelBBI = UIBarButtonItem(image: #imageLiteral(resourceName: "Cancel"), style: .plain, target: self, action: #selector(ViewController.cancelAction(_:)))
        cancelBBI.width = 20
        return cancelBBI
    }()
    lazy var doneBBI: UIBarButtonItem = {
        let doneBBI = UIBarButtonItem(image: #imageLiteral(resourceName: "Done"), style: .plain, target: self, action: #selector(ViewController.doneAction(_:)))
        doneBBI.width = 20
        return doneBBI
    }()
    lazy var addBBI: UIBarButtonItem = {
        let addBBI = UIBarButtonItem(image: #imageLiteral(resourceName: "Add"), style: .plain, target: self, action: #selector(ViewController.addAction(_:)))
        addBBI.width = 20
        return addBBI
    }()
    
    var displayModels = [Setting]()
    var editClicked = false
    lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: [SwitchLanguageTool.getLocalString(of: "Display"), SwitchLanguageTool.getLocalString(of: "Cache")])
        segmentedControl.addTarget(self, action: #selector(ViewController.segmentedDidSelect(with:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    var displayMode: DisplayModel = .display
    
    lazy var searchC: UISearchController = {
        weak var weakSelf = self
        let searchC = UISearchController(searchResultsController: nil)
        searchC.searchResultsUpdater = self
        searchC.delegate = self
        searchC.obscuresBackgroundDuringPresentation = false;
        searchC.searchBar.placeholder = SwitchLanguageTool.getLocalString(of: "SearchPlaceHolder")
        return searchC
    }()
    var keywords: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.allowsSelectionDuringEditing = false
        
        navigationItem.leftBarButtonItem = settingBBI
        navigationItem.rightBarButtonItem = editBBI
        
        view.addSubview(tableView)
        
        title = SwitchLanguageTool.getLocalString(of: "Display")
        navigationItem.titleView = segmentedControl
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.searchController = searchC
            navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
            navigationItem.hidesSearchBarWhenScrolling = true
        } else {
            // Fallback on earlier versions
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let realm = try! Realm()
        displayModels.removeAll()
        displayModels.append(contentsOf: realm.objects(Setting.self).filter("isDeleted = false").sorted(byKeyPath: "sortNum", ascending: true))
        searchC.isActive = false
        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["tableView": tableView]
        let hc = NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views)
        let vc = NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: views)
        
        view.addConstraints(hc)
        view.addConstraints(vc)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if targetEnvironment(simulator)
            if UserDefaults.standard.object(forKey: "isFirstOpen") as! Bool == true {
            print("this is a simulator!")
            let alertVC = UIAlertController(title: "Warning", message: "This is a simulator!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                alertVC.dismiss(animated: true, completion: nil)
            })
            alertVC.addAction(action)
            present(alertVC, animated: true, completion: {
            })
            }
        #else
        #endif
        
        if UserDefaults.standard.object(forKey: "isFirstOpen") != nil && UserDefaults.standard.object(forKey: "isFirstOpen") as! Bool != true  && displayMode == .display {
            
            let realm = try! Realm()
            if realm.objects(Setting.self).filter("isDeleted = false && type = 'system'").count != 0 && isBiggerThan11 {
                let alertC = UIAlertController(title: SwitchLanguageTool.getLocalString(of: "deleteSystemAction"), message: SwitchLanguageTool.getLocalString(of: "deleteSystemActionMessage"), preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                })
                alertC.addAction(OKAction)
                present(alertC, animated: true, completion: {
                })
            }
        }
        refresh()
    }
    
    @objc func segmentedDidSelect(with segC: UISegmentedControl) {
        tapticEngine()
        switch segC.selectedSegmentIndex {
        case 0:
            title = SwitchLanguageTool.getLocalString(of: "Display")
            if !editClicked {
                displayMode = .display
                navigationItem.rightBarButtonItems = []
                navigationItem.rightBarButtonItem = editBBI
                navigationItem.leftBarButtonItem = settingBBI
                refresh()
            }
            break
        case 1:
            title = SwitchLanguageTool.getLocalString(of: "Cache")
            if editClicked == true {
                SVProgressHUD.showError(withStatus: SwitchLanguageTool.getLocalString(of: "Please cancel or save your configuration."))
                segC.selectedSegmentIndex = 0
            } else {
                displayMode = .cache
                navigationItem.rightBarButtonItems = []
                navigationItem.rightBarButtonItem = addBBI
                refresh()
            }
            break
        default:
            break
        }
    }
    
    func refresh() {
        if displayMode == .display {
            displayModels.removeAll()
            let realm = try! Realm()
            if (keywords != nil && keywords != "") {
                displayModels.append(contentsOf: realm.objects(Setting.self).filter("isDeleted = false && (name contains '\(keywords ?? "")' || action contains '\(keywords ?? "")')").sorted(byKeyPath: "sortNum", ascending: true))
            } else {
                displayModels.append(contentsOf: realm.objects(Setting.self).filter("isDeleted = false").sorted(byKeyPath: "sortNum", ascending: true))
            }
            tableView.setEditing(false, animated: true)
            tableView.allowsSelectionDuringEditing = false
            tableView.reloadData()
        } else {
            displayModels.removeAll()
            tableView.setEditing(true, animated: true)
            tableView.allowsSelectionDuringEditing = true
            tableView.reloadData()
        }
    }
    
    func updateSortNum() {
        
        let realm = try! Realm()
        print(displayModels)
        
        let models = realm.objects(Setting.self).filter("isDeleted = false")
        
        for node in models.enumerated() {
            if displayModels.contains(node.element) {
                try! realm.write {
                    let model = node.element
                    model.sortNum = NSNumber.init(value: displayModels.index(of: node.element)!)
                    realm.add(model, update: true)
                }
            } else {
                try! realm.write {
                    let model = node.element
                    model.isDeleted = true
                    model.sortNum = NSNumber.init(value: -1)
                    realm.add(model, update: true)
                }
            }
        }
        
        displayModels.removeAll()
        displayModels.append(contentsOf: realm.objects(Setting.self).filter("isDeleted = false").sorted(byKeyPath: "sortNum", ascending: true))
        
    }
    
    @objc func deleteBBIAction(_ sender: Any) {
        tapticEngine()
        let indexPaths = tableView.indexPathsForSelectedRows!.sorted(by: >)
        for indexPath in indexPaths {
            displayModels.remove(at: indexPath.row)
        }
        
        deleteBBI.isEnabled = false
        tableView.deleteRows(at: tableView.indexPathsForSelectedRows!, with: .automatic)
    }
    
    @objc func settingBBIDidSelected(_ sender: Any) {
        tapticEngine()
        let aboutVC = AboutViewController()
        navigationController?.pushViewController(aboutVC, animated: true)
    }
    
    @objc func editAction(_ sender: Any) {
        tapticEngine()
        editClicked = true
        deleteBBI.isEnabled = false
        navigationItem.rightBarButtonItems = [doneBBI, deleteBBI]
        
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        navigationItem.leftBarButtonItem = cancelBBI
        doneBBI.isEnabled = false
        deleteBBI.isEnabled = false
    }

    @objc func cancelAction(_ sender: Any) {
        tapticEngine()
        editClicked = false
        tableView.setEditing(false, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1, execute: {
            
            let realm = try! Realm()
            self.displayModels.removeAll()
            self.displayModels.append(contentsOf: realm.objects(Setting.self).filter("isDeleted = false").sorted(byKeyPath: "sortNum", ascending: true))
            
            self.tableView.reloadData()
        })
        navigationItem.leftBarButtonItem = settingBBI
        navigationItem.rightBarButtonItems = []
        navigationItem.rightBarButtonItem = editBBI
    }
    
    @objc func doneAction(_ sender: Any) {
        tapticEngine()
        updateSortNum()
        editClicked = false
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        navigationItem.leftBarButtonItem = settingBBI
        navigationItem.rightBarButtonItems = []
        navigationItem.rightBarButtonItem = editBBI

    }
    
    @objc func addAction(_ sender: Any) {
        tapticEngine()
        let textInputVC = TextInputViewController()
        weak var weakSelf = self
        textInputVC.actionCanBeEdit = true
        textInputVC.reloadAction = {
            weakSelf?.tableView.reloadData()
        }
        navigationController?.pushViewController(textInputVC, animated: true)
    }

    func tapticEngine() {
        if UserDefaults.init(suiteName: "group.chengluffy.app-Prefs")?.value(forKey: "shock") == nil || UserDefaults.init(suiteName: "group.chengluffy.app-Prefs")?.value(forKey: "shock") as! Bool == true {
            let generator = UIImpactFeedbackGenerator.init(style: .light)
            generator.prepare()
            generator.impactOccurred()
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if displayMode == .display {
            return 1
        } else {
            if isBiggerThan11 {
                return 2
            } else {
                return 3
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if displayMode == .display {
            return displayModels.count
        } else {
            let realm = try! Realm()
            if section == 2 {
                if (keywords != nil && keywords != "") {
                    return realm.objects(Setting.self).filter("isDeleted = true && type = '\(ActionType.system.rawValue)' && (name contains '\(keywords ?? "")' || action contains '\(keywords ?? "")')").count
                } else {
                    return realm.objects(Setting.self).filter("isDeleted = true && type = '\(ActionType.system.rawValue)'").count
                }
            } else if section == 1 {
                if (keywords != nil && keywords != "") {
                    return realm.objects(Setting.self).filter("isDeleted = true && type = '\(ActionType.custom.rawValue)' && (name contains '\(keywords ?? "")' || action contains '\(keywords ?? "")')").count
                } else {
                    return realm.objects(Setting.self).filter("isDeleted = true && type = '\(ActionType.custom.rawValue)'").count
                }
            } else if section == 0 {
                if (keywords != nil && keywords != "") {
                    return realm.objects(Setting.self).filter("isDeleted = true && type = '\(ActionType.clipboard.rawValue)' && (name contains '\(keywords ?? "")' || action contains '\(keywords ?? "")')").count
                } else {
                    return realm.objects(Setting.self).filter("isDeleted = true && type = '\(ActionType.clipboard.rawValue)'").count
                }
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if displayMode == .display {
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            if cell == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            }
            let model = displayModels[indexPath.row]
            cell!.textLabel?.text = SwitchLanguageTool.getLocalString(of: model.name)
            cell!.detailTextLabel?.text = model.action.removingPercentEncoding
            cell?.textLabel?.adjustsFontSizeToFitWidth = true
            cell?.detailTextLabel?.adjustsFontSizeToFitWidth = true
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            if cell == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            }
            
            let realm = try! Realm()
            
            var typeStr = ""
            switch indexPath.section {
            case 0:
                typeStr = ActionType.clipboard.rawValue
                break
            case 1:
                typeStr = ActionType.custom.rawValue
                break
            case 2:
                typeStr = ActionType.system.rawValue
                break
            default: break
            }
            
            if (keywords != nil && keywords != "") {
                cell!.textLabel?.text = SwitchLanguageTool.getLocalString(of: realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)' && (name contains '\(keywords ?? "")' || action contains '\(keywords ?? "")')").sorted(byKeyPath: "sortNum", ascending: true)[indexPath.row].name)
                cell!.detailTextLabel!.text = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)' && (name contains '\(keywords ?? "")' || action contains '\(keywords ?? "")')").sorted(byKeyPath: "sortNum", ascending: true)[indexPath.row].action.removingPercentEncoding!
            } else {
                cell!.textLabel?.text = SwitchLanguageTool.getLocalString(of: realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)'").sorted(byKeyPath: "sortNum", ascending: true)[indexPath.row].name)
                cell!.detailTextLabel!.text = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)'").sorted(byKeyPath: "sortNum", ascending: true)[indexPath.row].action.removingPercentEncoding!
            }
            cell?.detailTextLabel?.adjustsFontSizeToFitWidth = true
            cell?.textLabel?.adjustsFontSizeToFitWidth = true
            return cell!

        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return displayMode == .display
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if displayMode == .display {
            if editClicked {
                return UITableViewCellEditingStyle.init(rawValue: UITableViewCellEditingStyle.insert.rawValue | UITableViewCellEditingStyle.delete.rawValue)!
            } else {
                return .delete
            }
        } else {
            return .insert
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        tapticEngine()
        let realm = try! Realm()
        if editingStyle == .insert {
            DispatchQueue.main.async {
                var typeStr = ""
                switch indexPath.section {
                case 0:
                    typeStr = ActionType.clipboard.rawValue
                    break
                case 1:
                    typeStr = ActionType.custom.rawValue
                    break
                case 2:
                    typeStr = ActionType.system.rawValue
                    break
                default: break
                }
                try! realm.write {
                    if (self.keywords != nil && self.keywords != "") {
                        let model = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)' && (name contains '\(self.keywords ?? "")' || action contains '\(self.keywords ?? "")')").sorted(byKeyPath: "sortNum", ascending: true)[indexPath.row]
                        model.sortNum = NSNumber.init(value: realm.objects(Setting.self).filter("isDeleted = false").count)
                        model.isDeleted = false
                        realm.add(model, update: true)
                    } else {
                        let model = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)'").sorted(byKeyPath: "sortNum", ascending: true)[indexPath.row]
                        model.sortNum = NSNumber.init(value: realm.objects(Setting.self).filter("isDeleted = false").count)
                        model.isDeleted = false
                        realm.add(model, update: true)
                    }
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if displayMode == .display {
            print("editing")
            deleteBBI.isEnabled = false
            doneBBI.isEnabled = false
        }
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if displayMode == .display {
            settingBBI.isEnabled = true
            editBBI.isEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if displayMode == .display {
            print(sourceIndexPath, destinationIndexPath)
            let model = displayModels[sourceIndexPath.row]
            displayModels.remove(at: sourceIndexPath.row)
            displayModels.insert(model, at: destinationIndexPath.row)
            doneBBI.isEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if displayMode == .display {
            if !editClicked {
                var action: String?
                let realm = try! Realm()
                let model: Setting?
                if (keywords != nil && keywords != "") {
                    model = realm.objects(Setting.self).filter("isDeleted = false && (name contains '\(keywords ?? "")' || action contains '\(keywords ?? "")')").sorted(byKeyPath: "sortNum", ascending: true)[indexPath.row]
                } else {
                    model = realm.objects(Setting.self).filter("isDeleted = false && sortNum = \(indexPath.row)").first!
                }
                
                if model?.type == ActionType.system.rawValue {
                    action = "app-\(model!.action!)"
                } else if model?.type == ActionType.custom.rawValue {
                    action = model?.action
                    if action?.contains("[clipboard]") ?? false {
                        let paste = UIPasteboard.general
                        action = action?.components(separatedBy: "[clipboard]").joined(separator: paste.string?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
                    } else if action?.contains("%5Bclipboard%5D") ?? false {
                        let paste = UIPasteboard.general
                        action = action?.components(separatedBy: "%5Bclipboard%5D").joined(separator: paste.string?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
                    }
                } else if model?.type == ActionType.clipboard.rawValue {
                    action = ClipboardActionTool.performAction(model?.action ?? "")
                }
                guard action != "" else {
                    tableView.deselectRow(at: indexPath, animated: true)
                    return
                }
                
                tapticEngine()
                
                UIApplication.shared.open(URL.init(string: action!)!, options: [:]) { (ret) in
                    if ret == false {
                        
                        let alert = UIAlertController(title: SwitchLanguageTool.getLocalString(of: "Failed to open"), message: SwitchLanguageTool.getLocalString(of: "Please check the settings of ") + model!.name, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "OK"), style: .default, handler: { (_) in
                            tableView.deselectRow(at: indexPath, animated: true)
                        })
                        alert.addAction(okAction)
                        if self.searchC.isActive {
                            self.searchC.present(alert, animated: true, completion: nil)
                        } else {
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    } else {
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                    
                }
                
                
            } else {
                
                deleteBBI.isEnabled = true
                doneBBI.isEnabled = true
            }
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            let alertSheet = UIAlertController(title: SwitchLanguageTool.getLocalString(of: "Next"), message: nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Cancel"), style: .cancel) { (_) in
            }
            let editAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Edit"), style: .default) { (_) in
                self.tapticEngine()
                let realm = try! Realm()
                
                var typeStr = ""
                switch indexPath.section {
                case 0:
                    typeStr = ActionType.clipboard.rawValue
                    break
                case 1:
                    typeStr = ActionType.custom.rawValue
                    break
                case 2:
                    typeStr = ActionType.system.rawValue
                    break
                default: break
                }
                let TextInputVC = TextInputViewController()
                weak var weakSelf = self
                TextInputVC.reloadAction = {
                    weakSelf?.tableView.reloadData()
                }
                if (self.keywords != nil && self.keywords != "") {
//                    return realm.objects(Setting.self).filter("isDeleted = true && type = '\(ActionType.custom.rawValue)' && (name contains '\(keywords ?? "")' || action contains '\(keywords ?? "")')").count
                    TextInputVC.action = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)' && (name contains '\(self.keywords ?? "")' || action contains '\(self.keywords ?? "")')").sorted(byKeyPath: "sortNum", ascending: true)[indexPath.row].action
                    TextInputVC.name = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)' && (name contains '\(self.keywords ?? "")' || action contains '\(self.keywords ?? "")')").sorted(byKeyPath: "sortNum", ascending: true)[indexPath.row].name
                    TextInputVC.cate = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)' && (name contains '\(self.keywords ?? "")' || action contains '\(self.keywords ?? "")')").sorted(byKeyPath: "sortNum", ascending: true)[indexPath.row].type
                    TextInputVC.modelIsDeleted = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)' && (name contains '\(self.keywords ?? "")' || action contains '\(self.keywords ?? "")')").sorted(byKeyPath: "sortNum", ascending: true)[indexPath.row].isDeleted
                } else {
                    TextInputVC.action = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)'").sorted(byKeyPath: "sortNum", ascending: true)[indexPath.row].action
                    TextInputVC.name = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)'").sorted(byKeyPath: "sortNum", ascending: true)[indexPath.row].name
                    TextInputVC.cate = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)'").sorted(byKeyPath: "sortNum", ascending: true)[indexPath.row].type
                    TextInputVC.modelIsDeleted = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)'").sorted(byKeyPath: "sortNum", ascending: true)[indexPath.row].isDeleted
                }
                TextInputVC.isEdit = true
                
                if typeStr == ActionType.custom.rawValue {
                    TextInputVC.actionCanBeEdit = true
                }
                self.navigationController?.pushViewController(TextInputVC, animated: true)
            }
            let deleteAction = UIAlertAction(title: SwitchLanguageTool.getLocalString(of: "Delete"), style: .destructive) { (_) in
                self.tapticEngine()
                let realm = try! Realm()
                
                var typeStr = ""
                switch indexPath.section {
                case 0:
                    typeStr = ActionType.clipboard.rawValue
                    break
                case 1:
                    typeStr = ActionType.custom.rawValue
                    break
                case 2:
                    typeStr = ActionType.system.rawValue
                    break
                default: break
                }
                if (self.keywords != nil && self.keywords != "") {
                    let model = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)' && (name contains '\(self.keywords ?? "")' || action contains '\(self.keywords ?? "")')").sorted(byKeyPath: "sortNum", ascending: true)[indexPath.row]
                    try! realm.write {
                        realm.delete(model)
                    }
                } else {
                    let model = realm.objects(Setting.self).filter("isDeleted = true && type = '\(typeStr)'").sorted(byKeyPath: "sortNum", ascending: true)[indexPath.row]
                    try! realm.write {
                        realm.delete(model)
                    }
                }
                
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            alertSheet.addAction(cancelAction)
            alertSheet.addAction(editAction)
            alertSheet.addAction(deleteAction)
            
            let presentC = alertSheet.popoverPresentationController
            if (presentC != nil) {
                presentC?.sourceView = tableView.cellForRow(at: indexPath)
                presentC?.sourceRect = (tableView.cellForRow(at: indexPath)?.bounds)!
                presentC?.permittedArrowDirections = .any
            }
            if searchC.isActive {
                searchC.present(alertSheet, animated: true, completion: nil)
            } else {
                present(alertSheet, animated: true, completion: nil)
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if displayMode == .display {
            if tableView.indexPathsForSelectedRows?.count == nil {
                deleteBBI.isEnabled = false
            } else {
                deleteBBI.isEnabled = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if displayMode == .display {
            let edit = UITableViewRowAction(style: .normal, title: SwitchLanguageTool.getLocalString(of: "Edit"), handler: { (edit, indexPath) in
                self.tapticEngine()
                let textInputVC = TextInputViewController()
                weak var weakSelf = self
                textInputVC.reloadAction = {
                    weakSelf?.tableView.reloadData()
                }
                let realm = try! Realm()
                if (self.keywords != nil && self.keywords != "") {
                    let model = realm.objects(Setting.self).filter("isDeleted = false && (name contains '\(self.keywords ?? "")' || action contains '\(self.keywords ?? "")')").sorted(byKeyPath: "sortNum", ascending: true)[indexPath.row]
                    textInputVC.action = model.action.removingPercentEncoding!
                    textInputVC.name = model.name
                    textInputVC.cate = model.type
                    textInputVC.modelIsDeleted = model.isDeleted
                    textInputVC.isEdit = true
                    textInputVC.sortNum = model.sortNum
                } else {
                    textInputVC.action = realm.objects(Setting.self).filter("isDeleted = false && sortNum = \(indexPath.row)").first!.action.removingPercentEncoding!
                    textInputVC.name = realm.objects(Setting.self).filter("isDeleted = false && sortNum = \(indexPath.row)").first!.name
                    textInputVC.cate = realm.objects(Setting.self).filter("isDeleted = false && sortNum = \(indexPath.row)").first!.type
                    textInputVC.modelIsDeleted = realm.objects(Setting.self).filter("isDeleted = false && sortNum = \(indexPath.row)").first!.isDeleted
                    textInputVC.isEdit = true
                    textInputVC.sortNum = realm.objects(Setting.self).filter("isDeleted = false && sortNum = \(indexPath.row)").first!.sortNum
                }
                
                if textInputVC.cate == ActionType.custom.rawValue {
                    textInputVC.actionCanBeEdit = true
                }
                
                self.navigationController?.pushViewController(textInputVC, animated: true)
            })
            edit.backgroundColor = UIColor.darkGray
            
            let copy = UITableViewRowAction(style: .normal, title: SwitchLanguageTool.getLocalString(of: "Copy")) { (_, indexPath) in
                self.tapticEngine()
                let cell = tableView.cellForRow(at: indexPath)
                let action = cell!.detailTextLabel!.text
                
                let pboard = UIPasteboard.general
                pboard.string = action
                let alertVC = UIAlertController.init(title: SwitchLanguageTool.getLocalString(of: "action has been copied"), message: "", preferredStyle: .alert)
                weak var weakSelf = self
                self.present(alertVC, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                        weakSelf!.dismiss(animated: true, completion: {
                        })
                    })
                }
            }
            
            let delete = UITableViewRowAction(style: .default, title: SwitchLanguageTool.getLocalString(of: "Delete"), handler: { (delete, indexPath) in
                self.tapticEngine()
                self.displayModels.remove(at: indexPath.row)
                self.updateSortNum()
                self.editBBI.isEnabled = true
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            })
            delete.backgroundColor = UIColor.red
            
            return [delete, edit, copy]
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if displayMode == .cache {
            var typeTitle = ""
            let realm = try! Realm()
            switch section {
            case 0:
                typeTitle = SwitchLanguageTool.getLocalString(of: "Clipboard Action")
                if realm.objects(Setting.self).filter("isDeleted = true && type = '\(ActionType.clipboard.rawValue)'").count == 0 {
                    typeTitle = ""
                }
                break
            case 1:
                typeTitle = SwitchLanguageTool.getLocalString(of: "Custom Action")
                if realm.objects(Setting.self).filter("isDeleted = true && type = '\(ActionType.custom.rawValue)'").count == 0 {
                    typeTitle = ""
                }
                break
            case 2:
                typeTitle = SwitchLanguageTool.getLocalString(of: "System Action")
                if realm.objects(Setting.self).filter("isDeleted = true && type = '\(ActionType.system.rawValue)'").count == 0 {
                    typeTitle = ""
                }
                break
            default:
                break
            }
            return typeTitle
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
}

extension ViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        debugPrint(searchController.searchBar.text ?? "nil")
        let text = searchController.searchBar.text ?? ""
        keywords = text
        refresh()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        keywords = nil
        refresh()
    }
}


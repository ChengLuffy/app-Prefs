//
//  Setting.swift
//  app-Prefs
//
//  Created by 成殿 on 2017/1/21.
//  Copyright © 2017年 成璐飞. All rights reserved.
//

import Foundation
import IceCream
import RealmSwift
import CloudKit

class Setting: Object {
    @objc dynamic var name: String!
    @objc dynamic var action: String!
    @objc dynamic var type = ActionType.system.rawValue
    @objc dynamic var isHidden: Bool = false
    @objc dynamic var isDeleted: Bool = false
    @objc dynamic var sortNum: NSNumber = -1
    var ActionTypeEnum: ActionType {
        get {
            return ActionType(rawValue: type)!
        }
        set {
            type = newValue.rawValue
        }
    }
    
    override static func primaryKey() -> String? {
        return "name"
    }
}

enum ActionType: String {
    case system
    case custom
    case clipboard
}

// MARK: - IceCream
extension Setting: CKRecordConvertible {
    // Require blank
}

extension Setting: CKRecordRecoverable {
    // Require blank
}

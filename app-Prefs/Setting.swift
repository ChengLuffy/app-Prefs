//
//  Setting.swift
//  app-Prefs
//
//  Created by 成殿 on 2017/1/21.
//  Copyright © 2017年 成璐飞. All rights reserved.
//

import Foundation

import RealmSwift

class Setting: Object {
    dynamic var name: String!
    dynamic var action: String!
    dynamic var type = ActionType.system.rawValue
    dynamic var isDeleted: Bool = false
    dynamic var sortNum: NSNumber! = -1
    var ActionTypeEnum: ActionType {
        get {
            return ActionType(rawValue: type)!
        }
        set {
            type = newValue.rawValue
        }
    }
    
    override class func primaryKey() -> String? {
        return "name"
    }
}

enum ActionType: String {
    case system
    case custom
}

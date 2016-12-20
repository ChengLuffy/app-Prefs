//
//  CollectionViewCell.swift
//  app-Prefs
//
//  Created by 成璐飞 on 2016/12/20.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    var prefs: String?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        label.adjustsFontSizeToFitWidth = true
    }

}

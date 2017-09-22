//
//  MapSuggest.swift
//  AppEvent
//
//  Created by Kata Mr on 1/5/17.
//  Copyright © 2017 Kata Mr. All rights reserved.
//

import UIKit

class MapSuggest: UICollectionViewCell {

    @IBOutlet weak var imgLeft: UIImageView!
    @IBOutlet weak var imgRight: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func selected() {
        self.backgroundColor = UIColor.init(hexString: "#fd04d8")
        self.lblTitle.tintColor = UIColor.white
    }
    
    func nonSelected() {
        self.backgroundColor = UIColor.white
        self.lblTitle.tintColor = UIColor.lightGray
    }
    
    func setup (_ index: Int) {
        index > 1 ? (imgLeft.frame.size.width = 0) : (imgRight.frame.size.width = 0)
    }

}

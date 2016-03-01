//
//  RatingsCell.swift
//  EvertonNewsApp
//
//  Created by Dan Taylor on 24/01/2016.
//  Copyright © 2016 Dan Taylor. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class RatingsCell: PFTableViewCell {

    @IBOutlet weak var rating: UIStepper!
    @IBOutlet weak var playerName: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    @IBAction func ratingChange(sender: AnyObject) {
        
        ratingLabel.text = "\(Int(rating.value))"
        
    }
}

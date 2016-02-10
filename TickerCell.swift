//
//  TickerCell.swift
//  Chore Balance
//
//  Created by Yifan Zhang on 2/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class TickerCell: UICollectionViewCell {

    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var activityLabel: UILabel!
    
    @IBOutlet var scoreLabel: UILabel!
    
    func setCell(date: NSDate, description: String, score: Int) {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "M/d"
        
        let dateString = formatter.stringFromDate(date)
        
        self.dateLabel.text = dateString
        
        self.activityLabel.text = description
        
        self.scoreLabel.text = "+\(score)"
        
    }
    
}

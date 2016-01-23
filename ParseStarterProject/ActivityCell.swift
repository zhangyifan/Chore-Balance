//
//  ActivityCell.swift
//  Chore Balance
//
//  Created by Yifan Zhang on 1/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ActivityCell: UITableViewCell {
    
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var descriptionLabel: UILabel!
    
    @IBOutlet var scoreLabel: UILabel!
    
    func setCell(date: NSDate, description: String, score: Int) {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "M/d"
        
        let dateString = formatter.stringFromDate(date)
        
        self.dateLabel.text = dateString
        
        self.descriptionLabel.text = description
        
        self.scoreLabel.text = "+\(score)"
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  ToDoCell.swift
//  Chore Balance
//
//  Created by Yifan Zhang on 1/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ToDoCell: UITableViewCell {

    @IBOutlet var choreLabel: UILabel!
    
    @IBOutlet var lastDoneLabel: UILabel!
    
    @IBAction func DoButton(sender: AnyObject) {
    }
    
    func setCell(description: String, score: Int, lastDone: NSDate?) {
        
        choreLabel.text = description + " - \(score)"
        
        if lastDone == nil {
            
            lastDoneLabel.text = "Never"
            
        } else {
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "M/d"
            
            let dateString = formatter.stringFromDate(lastDone!)
            
            lastDoneLabel.text = "last " + dateString
        }
  
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

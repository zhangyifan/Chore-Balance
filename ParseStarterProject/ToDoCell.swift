//
//  ToDoCell.swift
//  Chore Balance
//
//  Created by Yifan Zhang on 1/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ToDoCell: UITableViewCell {

    //Main
    @IBOutlet var choreLabel: UILabel!
    
    @IBOutlet var lastDoneLabel: UILabel!
    
    @IBOutlet var doButtonOutlet: UIButton!
    
    @IBAction func DoButton(sender: AnyObject) {
    }
    
    //ChoreTableViewController 
    @IBOutlet var choreNameLabel: UILabel!
    
    @IBOutlet var scoreLabel: UILabel!
    
    @IBOutlet var tableLastDoneLabel: UILabel!
    
    @IBOutlet var tableDoButtonOutlet: UIButton!
    
    @IBAction func tableDoButton(sender: AnyObject) {
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
    
    func setTableCell(description: String, score: Int, lastDone: NSDate?) {
        
        choreNameLabel.text = description
        
        scoreLabel.text = "\(score)"
        
        if lastDone == nil {
            
            tableLastDoneLabel.text = "Never"
            
        } else {
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "M/d"
            
            let dateString = formatter.stringFromDate(lastDone!)
            
            tableLastDoneLabel.text = "last " + dateString
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

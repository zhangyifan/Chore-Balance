//
//  Chore.swift
//  Chore Balance
//
//  Created by Yifan Zhang on 1/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class Chore: PFObject, PFSubclassing {
    
    //Set up class to work with Parse
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "Chore"
    }
    
    //Attributes
    @NSManaged var name: String
    
    @NSManaged var score: Int
    
    @NSManaged var household: PFObject
    
    //Set up what querying Chores does
    override class func query() -> PFQuery? {
    //1
    let query = PFQuery(className: Chore.parseClassName())
    //2
    query.includeKey("household")
    return query
    }
    
    //Initialize
    init(name: String, score: Int, household: PFObject) {
        super.init()
        
        self.name = name
        self.score = score
        self.household = household
        
    }
    
    override init() {
        super.init()
    }
    
    func create(name: String, score: Int, household: PFObject, closure: (NSError?, Chore) -> Void) {
        
        let chore = Chore(name: name, score: score, household: household)
        
        chore.saveInBackgroundWithBlock({ (success, error) -> Void in
            
            closure(error, chore)
            
        })
        
    }
    
    func getLastDone(view: UIViewController) -> NSDate {
        
        var lastDone: NSDate? = nil
        
        let activityQuery = Activity.query()!
        
        activityQuery.whereKey("chore", equalTo: self)
        
        do {
            
            if let foundActivity = try? activityQuery.getFirstObject() {
                
                lastDone = foundActivity["completedAt"] as! NSDate
                
            } 
            
            
        } catch {
            
            UserViewController.displayAlert("Couldn't find activities", message: error as! String, view: view)
            
        }

        return lastDone!
    }
    
}

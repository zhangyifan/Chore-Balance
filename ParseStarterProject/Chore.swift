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
    
    @NSManaged var household: Household
    
    @NSManaged var lastDone: NSDate?
    
    @NSManaged var isDeleted: Bool
    
    //Set up what querying Chores does
    override class func query() -> PFQuery? {
    //1
    let query = PFQuery(className: Chore.parseClassName())
    //2
    query.includeKey("household")
    return query
    }
    
    //Initialize
    init(name: String, score: Int, household: Household, lastDone: NSDate?, isDeleted: Bool) {
        super.init()
        
        self.name = name
        self.score = score
        self.household = household
        self.lastDone = lastDone
        self.isDeleted = false
        
    }
    
    override init() {
        super.init()
    }
    
    func create(name: String, score: Int, household: Household, lastDone: NSDate?, closure: (NSError?, Chore) -> Void) {
        
        let chore = Chore(name: name, score: score, household: household, lastDone: lastDone, isDeleted: false)
        
        let acl = PFACL()
        acl.publicReadAccess = true
        acl.publicWriteAccess = true
        
        chore.ACL = acl
        
        chore.saveInBackgroundWithBlock({ (success, error) -> Void in
            
            closure(error, chore)
            
        })
        
    }
    
    func getLastDone(closure: (Activity?, NSError?) -> Void) {
        
        let activityQuery = Activity.query()!
    
        activityQuery.whereKey("chore", equalTo: self)
        
        activityQuery.getFirstObjectInBackgroundWithBlock() { (activity, error) -> Void in
            
            //Finds a last done activity
            if let foundActivity = activity as? Activity {
                
                self.lastDone = foundActivity.completedAt
                
                closure(foundActivity, nil)
                
            //No error but does not find a last done activity
            } else if error?.localizedDescription == "No results matched the query." {
                
                self.lastDone = nil
                
                closure(nil, nil)
                
            //Error
            } else {
                
                closure(nil, error)
                
            }
            
        }

    }
    
    func updateLastDone(closure: (NSError?) -> Void) {
        
        self.lastDone = NSDate()
        
        self.saveInBackgroundWithBlock { (success, error) -> Void in
            
            if error != nil {
                
                closure(error)
                
            } else {
         
                closure(nil)
                
            }
            
        }
        
    }
    
    func update(name: String, score: Int, isDeleted: Bool, closure: (NSError?) -> Void) {
        
        self.name = name
        
        self.score = score
        
        self.isDeleted = isDeleted
        
        self.saveInBackgroundWithBlock { (success, error) -> Void in
            
            if error != nil {
                
                closure(error)
                
            } else {
                
                closure(nil)
                
            }       
            
        }
        
    }
    
}

//
//  Activity.swift
//  Chore Balance
//
//  Created by Yifan Zhang on 1/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class Activity: PFObject, PFSubclassing {
    
    //Set up class to work with Parse
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "Activity"
    }
    
    //Attributes
    @NSManaged var user: User
    
    @NSManaged var chore: Chore
    
    @NSManaged var scoreStamp: Int
    
    @NSManaged var completedAt: NSDate
    
    //Set up what querying Activity does
    override class func query() -> PFQuery? {
    //1
    let query = PFQuery(className: Activity.parseClassName())
    //2
    query.includeKey("user")
    //3
    query.includeKey("chore")
    //4
    query.orderByDescending("completedAt")
    //5 cache
    query.cachePolicy = .NetworkElseCache
    return query
    }
    
    //Initialize
    init(user: User, chore: Chore, scoreStamp: Int, completedAt: NSDate) {
        super.init()
        
        self.user = user
        self.chore = chore
        self.scoreStamp = scoreStamp
        self.completedAt = completedAt
        
    }
    
    override init() {
        super.init()
    }

    func create (user: User, chore: Chore, scoreStamp: Int, completedAt: NSDate, closure: (NSError?, Activity) -> Void) {
        
        let activity = Activity(user: user, chore: chore, scoreStamp: scoreStamp, completedAt: completedAt)

        activity.saveInBackgroundWithBlock { (success, error) -> Void in
            
            closure(error, activity)

        }
        
    }    
}

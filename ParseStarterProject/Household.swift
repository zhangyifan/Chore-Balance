//
//  Household.swift
//  Chore Balance
//
//  Created by Yifan Zhang on 1/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class Household: PFObject, PFSubclassing {
    
    //Set up class to work with Parse
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "Household"
    }
    
    //Attributes
    @NSManaged var name: String
    
    @NSManaged var scoreFromDate: NSDate
    
    //Set up what querying Household does
    override class func query() -> PFQuery? {
        //1
        let query = PFQuery(className: Household.parseClassName())
        //2 cache
        query.cachePolicy = .NetworkElseCache
        return query
    }
    
    //Initialize
    init(name: String, scoreFromDate: NSDate) {
        super.init()
        
        self.name = name
        
        self.scoreFromDate = scoreFromDate
        
    }
    
    override init() {
        super.init()
    }
    
    func create(name: String, scoreFromDate: NSDate, closure: (NSError?, Household)-> Void) {
        
        let household = Household(name: name, scoreFromDate: scoreFromDate)
        
        let acl = PFACL()
        acl.publicReadAccess = true
        acl.publicWriteAccess = true
        
        household.ACL = acl
        
        household.saveInBackgroundWithBlock({ (success, error) -> Void in
            
            closure(error, household)
            
        })
        
    }
    
    //Query for all users in current user's household
    func getUsers(closure: ([PFObject]?, NSError?) -> Void) {
        
        let usersQuery = User.query()
        
        usersQuery!.whereKey("household", equalTo: self)
        
        usersQuery!.findObjectsInBackgroundWithBlock({ (users, error) -> Void in
            
            closure(users, error)
        })
    }
    
    //Search Parse for recent activities in household
    func getActivities(limit: Int?, closure: ([Activity]?, NSError?) -> Void) {

        let usersQuery = User.query()!

        usersQuery.whereKey("household", equalTo: self)
        
        usersQuery.cachePolicy = .NetworkElseCache
        
        usersQuery.findObjectsInBackgroundWithBlock { (users, error) -> Void in
            
            if error == nil {
                
                /*let mutableArray = NSMutableArray()
                
                for user in users! {
                    
                    mutableArray.addObject(user)
                }
                
                let userArray = mutableArray as! NSArray
                
                NSUserDefaults.standardUserDefaults().set
                    //setObject(userArray, forKey: "householdUsers")
                
                let savedUsers = NSUserDefaults.standardUserDefaults().objectForKey("householdUsers") as! [User]
                
                print("Saved users are: \(savedUsers)")*/
                
                let activitiesQuery = Activity.query()!
                
                activitiesQuery.whereKey("user", containedIn: users!)
                
                activitiesQuery.cachePolicy = .NetworkElseCache
                
                if limit != nil {
                    
                    activitiesQuery.limit = 4
                    
                } 
                
                activitiesQuery.findObjectsInBackgroundWithBlock({ (activities, error) -> Void in
                    
                    if error == nil {
                
                        if let foundActivities = activities as? [Activity] {
                            
                            closure(foundActivities, nil)
                            
                        } else {
                            
                            print("Couldn't downcast activities")
                        }
                        
                    } else {
                        
                        print(error)
                        closure(nil, error)
                        
                    }
                    
                    
                })
                
            } else {
                
                print(error)
                closure(nil, error)
                
            }
            
        }
        
    }
    
    //Query for all chores in current household
    func getChores(closure: ([Chore]?, NSError?) -> Void) {

        let choresQuery = Chore.query()
        
        choresQuery!.whereKey("household", equalTo: self)
        
        choresQuery!.findObjectsInBackgroundWithBlock({ (chores, error) -> Void in
            
            if error == nil {
                
                if let foundChores = chores as? [Chore] {
                    
                    closure(foundChores, nil)
                    
                } else {
                    
                    print("Couldn't downcast activities")
                }
                
            } else {
                
                closure(nil, error)
                
            }
        })
        
    }
    
    func updateScoreFromDate(date: NSDate, closure: (NSError?) -> Void) {
        
        self.scoreFromDate = date
        
        self.saveInBackgroundWithBlock { (success, error) -> Void in
            
            if error != nil {
                
                closure(error)
                
            } else {
                
                closure(nil)
                
            }
            
        }
        
    }
    
}

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
    
    //Set up what querying Household does
    override class func query() -> PFQuery? {
        //1
        let query = PFQuery(className: Household.parseClassName())
        return query
    }
    
    //Initialize
    init(name: String) {
        super.init()
        
        self.name = name
        
    }
    
    override init() {
        super.init()
    }
    
    func create(name: String, closure: (NSError?, Household)-> Void) {
        
        let household = Household(name: name)
        
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
    func getActivities(closure: ([Activity]?, NSError?) -> Void) {
        
        let usersQuery = User.query()!
        
        usersQuery.whereKey("household", equalTo: self)
        
        let activitiesQuery = Activity.query()!
        
        activitiesQuery.whereKey("user", matchesQuery: usersQuery)
        
        activitiesQuery.findObjectsInBackgroundWithBlock({ (activities, error) -> Void in
            
            if error == nil {
                
                if let foundActivities = activities as? [Activity] {
                    
                    closure(foundActivities, nil)
                    
                } else {
                    
                    print("Couldn't downcast activities")
                }
                
            } else {
                
                closure(nil, error)
                
            }
            
            
        })
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
    
}

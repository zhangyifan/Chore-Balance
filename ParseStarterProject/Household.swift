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
    
    //Update userList with all users in current user's household
    func getUsers(closure: ([PFObject]?, NSError?) -> Void) {
        
        let usersQuery = User.query()
        
        usersQuery!.whereKey("household", equalTo: self)
        
        usersQuery!.findObjectsInBackgroundWithBlock({ (users, error) -> Void in
            
            closure(users, error)
        })
    }
    
}

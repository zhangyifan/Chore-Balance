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
    func getUsers(closure: (NSError?) -> Void) {
        
        let usersQuery = User.query()
        
        usersQuery!.whereKey("household", equalTo: self)
        
        usersQuery!.findObjectsInBackgroundWithBlock({ (users, error) -> Void in
            
            if users != nil {
                
                //Clear userList
                userList.removeAll(keepCapacity: true)
                
                //For every user in household, sum up scores
                //In the future set monthly, weekly limits
                for user in users! {
                    
                    let parseUser = user as! PFUser
                    
                    let customUser = User(name: parseUser.username!, password: "randomPassword", household: parseUser["household"] as! PFObject)
                    
                    userList.append(customUser)
                    
                    customUser.getScore()
                }
                
            } else {
                
                closure(error)
                
            }
        })
    }
    
}

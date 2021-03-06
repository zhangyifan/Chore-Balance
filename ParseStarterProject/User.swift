//
//  User.swift
//  Chore Balance
//
//  Created by Yifan Zhang on 1/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

//REMEMBER: For custom subclasses, must also create Briding Header and import subclasses, then register all subclasses in AppDelegate to be able to downcast.

class User: PFUser {
    
    //Set up class to work with Parse
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    //Attributes
    
    @NSManaged var household: Household?
    
    //Set up what querying User does
    override class func query() -> PFQuery? {
        //1
        let query = PFUser.query()
        //2
        query!.includeKey("household")
        //3 cache
        query!.cachePolicy = .NetworkElseCache
        return query
    }
    
    //Initialize
    init(name: String, password: String, household: Household?) {
        super.init()
        
        //Remember username and password are super PFUser variables, not subclassable
        super.username = name
        self.household = household
        super.password = password
        
    }
    
    override init() {
        super.init()
    }
    
    func signUp(username: String, password: String, closure: (NSError?) -> Void ) {
        
        let user = User(name: username, password: password, household: nil)
        
        user.signUpInBackgroundWithBlock({ (success, error) -> Void in
            
            closure(error)
            
        })
        
    }
    
    func logIn(username: String, password: String, closure: (PFUser?, NSError?) -> Void ) {
        
        PFUser.logInWithUsernameInBackground(username, password: password, block: { (user, error) -> Void in
            
            closure(user, error)
            
        })
        
    }
 
    func getScore(closure: (Int?, NSError?) -> Void) {
        
        var score = 0
        
        let household = self.household! as! Household
        
        let scoresQuery = Activity.query()!
        
        scoresQuery.whereKey("user", equalTo: self)

        scoresQuery.whereKey("completedAt", greaterThanOrEqualTo: self.household!.scoreFromDate)
        
        scoresQuery.cachePolicy = .NetworkElseCache
      
        scoresQuery.findObjectsInBackgroundWithBlock({ (activities, error) -> Void in
            
            if let foundActivities = activities as? [Activity] {
                
                //sum up scores
                for activity in foundActivities {
                    
                    score += activity.scoreStamp
                    
                }
                
                closure(score, nil)
                
            } else {
                
                closure(nil, error!)
                
            }
        })
    }
    
}



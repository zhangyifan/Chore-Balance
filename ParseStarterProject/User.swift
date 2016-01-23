//
//  User.swift
//  Chore Balance
//
//  Created by Yifan Zhang on 1/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class User: PFUser {
    
    //Set up class to work with Parse
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    //Attributes
    
    @NSManaged var household: PFObject?
    
    //Set up what querying User does
    override class func query() -> PFQuery? {
        //1
        let query = PFUser.query()
        //2
        query!.includeKey("household")
        return query
    }
    
    //Initialize
    init(name: String, password: String, household: PFObject?) {
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
    

    
    func getScore() {
        
        var nameScores = [String:Int]() //"Dictionary with Name: Score"
        
        var score = 0
        
        let scoresQuery = Activity.query()!
        
        scoresQuery.whereKey("user", equalTo: self)
        
        scoresQuery.findObjectsInBackgroundWithBlock({ (activities, error) -> Void in
            
            if activities != nil {
                
                //sum up scores
                for activity in activities! {
                    
                    let foundActivity = Activity(user: activity["user"] as! PFUser, chore: activity["chore"] as! PFObject, scoreStamp: activity["scoreStamp"] as! Int, completedAt: activity["completedAt"] as! NSDate)
                    
                    if let scoreInt = foundActivity.scoreStamp as? Int {
                        
                        score += scoreInt
                        
                    }
                    
                }
                
                nameScores[self.username!] = score
                
            } /*else {
                
                UserViewController.displayAlert("Error with calculating scores", message: error!.description, view: view)
                
                refreshControl.endRefreshing()
                
            }*/
        })
    }
    
    //Search Parse for leaderboard for household
    class func getSortedMembers(view: UIViewController, refreshControl: UIRefreshControl, closure: ([String],[Int]) -> Void) {
        
        //Unsorted household members
        var nameScores = [String:Int]() //"Dictionary with Name: Score"
        
        let usersQuery = User.query()
        
        usersQuery!.whereKey("household", equalTo: User.currentUser()!.household!)
        
        usersQuery!.findObjectsInBackgroundWithBlock({ (users, error) -> Void in
            
            if users != nil {
                
                //Clear userList
                userList.removeAll(keepCapacity: true)
                
                //For every user in household, sum up scores
                //In the future set monthly, weekly limits
                for user in users! {
                    
                    let parseUser = user as! PFUser
                    
                    let customUser = User(name: parseUser.username!, password: "randomPassword", household: parseUser["household"] as? PFObject)
                    
                    userList.append(customUser)
                    
                    var score = 0
                    
                    let scoresQuery = Activity.query()!
                    
                    scoresQuery.whereKey("user", equalTo: parseUser)
                    
                    scoresQuery.findObjectsInBackgroundWithBlock({ (activities, error) -> Void in
                        
                        if activities != nil {
                            
                            //sum up scores
                            for activity in activities! {
                                
                                let foundActivity = Activity(user: activity["user"] as! PFUser, chore: activity["chore"] as! PFObject, scoreStamp: activity["scoreStamp"] as! Int, completedAt: activity["completedAt"] as! NSDate)
                                
                                if let scoreInt = foundActivity.scoreStamp as? Int {
                                    
                                    score += scoreInt
                                    
                                }
                                
                            }
                            
                            nameScores[customUser.username!] = score
                            
                            //Sort for leaderboard
                            var sortedNames = [String]()
                            var sortedScores = [Int]()
                            
                            for (name,score) in (Array(nameScores).sort{$0.1 > $1.1}) {
                                
                                sortedNames.append(name)
                                
                                sortedScores.append(score)
                                
                            }
                            
                            //Does this for every user.  Figure out some way to be more efficient?
                            closure(sortedNames,sortedScores)
                            
                        } else {
                            
                            UserViewController.displayAlert("Error with calculating scores", message: error!.description, view: view)
                            
                            refreshControl.endRefreshing()
                            
                        }
                        
                    })
                    
                }
                
                
                
            } else {
                
                UserViewController.displayAlert("Couldn't find people in your household", message: error!.description, view: view)
                
                refreshControl.endRefreshing()
                
            }
            
        })
        
    }
    
}



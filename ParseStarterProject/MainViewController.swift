//
//  MainViewController.swift
//  Chore Balance
//
//  Created by Yifan Zhang on 1/14/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

//TODO - SETTINGS?  Just have logout right now but in the future we will want a settings page.
//TODO - Cache leaderboard?  Check for refresh time?

//List of users in household.  Maybe cache in the future?  TODO
var userList = [User]()

var choreArray = [Chore]()

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var toDoTableView: UITableView!
    
    @IBOutlet var activityTableView: UITableView!
    
    @IBOutlet var scrollView: UIScrollView!
    
    //Current Scores section
    @IBOutlet var winnerLabel: UILabel!
    
    @IBOutlet var secondLabel: UILabel!
    
    //Activities section
    var activityList = [Activity]()
    

    //Refresh function
    var lastRefreshTime = NSDate()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        lastRefreshTime = NSDate()
        
        if User.currentUser() != nil {
            
            //********CURRENT SCORES SECTION**************
            
            //Find all sorted users in the same household
            MembersTableViewController.getSortedUsers() {(names: [String]?, scores: [Int]?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    if names!.count > 0 && scores!.count > 0 {
                        
                        self.winnerLabel.text = names![0] + " - \(scores![0])"
                        
                        if names!.count > 1 && scores!.count > 1 {
                            
                            self.secondLabel.text = names![1] + " - \(scores![1])"
                            
                        }
                        
                    }
                    
                    refreshControl.endRefreshing()
                    
                } else {
                    
                    UserViewController.displayAlert("Couldn't load household members", message: error!.description, view: self)
                    
                    refreshControl.endRefreshing()
                    
                }
                
            }
            
            
            //********ACTIVITY FEED SECTION**************
            ActivitiesTableViewController.getActivities() {(activities: [Activity]?, error: NSError?)-> Void in
                
                if error == nil {
                    
                    self.activityList = activities!
                    
                    self.activityTableView.reloadData()
                    
                } else {
                    
                    UserViewController.displayAlert("Couldn't find activities", message: error!.description, view: self)
                    
                    refreshControl.endRefreshing()
                    
                }
                
            }
            
            //********CHORES SECTION**************
            /*MainViewController.getChores({ () -> Void in
                
                self.toDoTableView.reloadData()
                
            })*/
            
        } else {
            
            //catch and make user login again TODO
            print("no current user logged in")
            
        }
        
        //Maybe in the future have caching of data?
        
        
    }
    
    
    
    
    
    //Use activityList and remove duplicate Chores.  TODO: In the future, check that activityList has been refreshed recently.
    /*class func getChores(closure: () -> Void) {
        
        //TODO THIS DOESN'T WORK IF NO ACTIVITIES HAVE BEEN DONE.  NEED TO REDO
        choreArray.removeAll(keepCapacity: true)

        for activity in activityList {
            
            choreArray.append(activity.chore as! Chore)
            
        }
        
        //Remove duplicate chores
        let choreSet = NSOrderedSet(array: choreArray)
        
        //Turn Set back into array
        choreArray.removeAll(keepCapacity: true)
    
        for object in choreSet {
            
            choreArray.append(object as! Chore)
            
        }
        
        closure()
        
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Pull to refresh
        self.scrollView.addSubview(self.refreshControl)
        
        //Set up tables and stuff
        toDoTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "toDoCell")
        activityTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "activityCell")

        
    }
    
    //Hide Navigation Controller Back button
    override func viewWillAppear(animated: Bool) {
        
        self.navigationItem.hidesBackButton = true
        
        self.navigationController?.navigationBarHidden = true
        
        //Check if data has been reloaded recently, and if so reload it. TODO
        handleRefresh(refreshControl)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count:Int?
        
        if tableView == self.toDoTableView {
            
            //Calculate rows of Chores
            count = choreArray.count
            
        }
        
        if tableView == self.activityTableView {
            
            //Calculate rows of activities
            count = activityList.count
        }
        
        return count!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell?
        
        if tableView == self.toDoTableView {
            
            let toDoCell: ToDoCell = tableView.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath) as! ToDoCell
            
            let chore = choreArray[indexPath.row]
            
            let choreName = chore.name
            
            let choreScore = chore.score
            
            let lastDoneDate = chore.getLastDone(self)
            
            toDoCell.setCell(choreName, score: choreScore, lastDone: lastDoneDate)
            
            cell = toDoCell
            
            
        }
        
        if tableView == self.activityTableView {
            
            let activityCell: ActivityCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ActivityCell
            
            let activity = activityList[indexPath.row]
            
            let completedDate = activity.completedAt
            
            let choreName = activity.chore["name"] as! String
            
            let userName = activity.user["username"] as! String
            
            let description = userName + " did " + choreName
            
            let score = activity.scoreStamp
            
            activityCell.setCell(completedDate, description: description, score: score)
            
            cell = activityCell
        }
        
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == self.toDoTableView {
            
            self.performSegueWithIdentifier("showChores", sender: self)
            
        }
        
        if tableView == self.activityTableView {
            
            self.performSegueWithIdentifier("showActivityFeed", sender: self)
            
        }
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation - how to do this to pass list of users?

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}

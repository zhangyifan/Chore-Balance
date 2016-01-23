//
//  ActivitiesTableViewController.swift
//  Chore Balance
//
//  Created by Yifan Zhang on 1/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class ActivitiesTableViewController: UITableViewController {

    var activityList = [Activity]()
    
    var refresher: UIRefreshControl!
    
    func refresh() {
        
        ActivitiesTableViewController.getActivities() {(activities: [Activity]?, error: NSError?)-> Void in
            
            if error == nil {
                
                self.activityList = activities!
                
                self.tableView.reloadData()
                
                self.refresher.endRefreshing()
                
            } else {
                
                UserViewController.displayAlert("Couldn't find activities", message: error!.description, view: self)
                
                self.refresher.endRefreshing()
                
            }
            
        }
    }
    
    //Search Parse for recent activities
    class func getActivities(closure: ([Activity]?, NSError?) -> Void) {
        
        let usersQuery = User.query()!
        
        usersQuery.whereKey("household", equalTo: User.currentUser()!["household"])
        
        let activitiesQuery = Activity.query()!
        
        activitiesQuery.whereKey("user", matchesQuery: usersQuery)
        
        /*I think this is not needed anymore
        activitiesQuery.orderByDescending("completedAt")
        
        activitiesQuery.includeKey("chore")
        
        activitiesQuery.includeKey("user")*/
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refresher = UIRefreshControl()
        //refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        
    }
    
    //Unhide Navigation Controller Back button
    override func viewWillAppear(animated: Bool) {
        
        self.navigationItem.hidesBackButton = false
        
        self.navigationController?.navigationBarHidden = false
        
        refresh()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return activityList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: ActivityCell = tableView.dequeueReusableCellWithIdentifier("cell2", forIndexPath: indexPath) as! ActivityCell
        
        let activity = activityList[indexPath.row]
        
        let completedDate = activity.completedAt
        
        let choreName = activity.chore["name"] as! String
        
        let userName = activity.user["username"] as! String
        
        let description = userName + " did " + choreName
        
        let score = activity.scoreStamp
        
        cell.setTableCell(completedDate, description: description, score: score)
        
        return cell
    
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

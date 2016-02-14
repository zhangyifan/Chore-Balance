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
        
        if let household = User.currentUser()!.household! as? Household {
            
            household.getActivities(nil) {(activities: [Activity]?, error: NSError?)-> Void in
                
                if error == nil {
                    
                    self.activityList = activities!
                    
                    self.tableView.reloadData()
                    
                    self.refresher.endRefreshing()
                    
                } else {
                    
                    UserViewController.displayAlert("Couldn't find activities", message: error!.localizedDescription, view: self)
                    
                    self.refresher.endRefreshing()
                    
                }
                
            }
            
        } else {
            
            //Handle if user has null household TODO
            print("User has no household")
            
        }
        
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
        
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 132.0/255.0, green: 220.0/255.0, blue: 154.0/255.0, alpha: 1.0)
        
        self.navigationController!.navigationBar.alpha = 1.0
        
        self.navigationController?.navigationBar.clipsToBounds = false
        
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
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let deletedActivity = activityList[indexPath.row]
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "M/d"
            let dateString = formatter.stringFromDate(deletedActivity.completedAt)
            
            let deleteActivityAlert = UIAlertController(title: "Your activity will be deleted", message: "Just making sure you want to delete doing \(deletedActivity.chore.name) on \(dateString). This can't be undone.", preferredStyle: UIAlertControllerStyle.Alert)
            
            deleteActivityAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                
                //Nothing happens
                
            }))
            
            deleteActivityAlert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (action: UIAlertAction!) in
                
                // Delete the row from the data source
                self.activityList[indexPath.row].deleteInBackgroundWithBlock({ (success, error) -> Void in
                    
                    if success == true {
                        
                        self.activityList.removeAtIndex(indexPath.row)
                        
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        
                    } else if self.activityList[indexPath.row].user != User.currentUser() {
                        
                        //Can't edit another user's activity
                        UserViewController.displayAlert("You can't edit someone else's activity", message: "This activity was not done by you.  Please ask them to edit it.", view: self)
                        
                    } else {
                        
                        UserViewController.displayAlert("Couldn't delete activity", message: error!.localizedDescription, view: self)
                        
                    }
                })
                
            }))
            
            presentViewController(deleteActivityAlert, animated: true, completion: nil)
 
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
            //We don't want this right now
        }
    }
    

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

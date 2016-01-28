//
//  ChoresTableViewController.swift
//  Chore Balance
//
//  Created by Yifan Zhang on 1/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class ChoresTableViewController: UITableViewController {

    var choreList = [Chore]()
    
    var refresher: UIRefreshControl!
    
    func refresh() {
        
        if let household = User.currentUser()!.household! as? Household {
            
            household.getChores() { (chores: [Chore]?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    self.choreList = chores!
                    
                    var foundDates = 0
                    
                    for chore in chores! {
                        
                        chore.getLastDone() {(activity: Activity?, error: NSError?) -> Void in
                            
                            if error == nil {
                                
                                foundDates++
                                
                                //Check to see if all dates have been loaded
                                if foundDates == chores?.count {
                                    
                                    //Sort so that the ones never done are first
                                    self.choreList.sortInPlace({ (item1, item2) -> Bool in
                                        let t1 = item1.lastDone ?? NSDate.distantPast()
                                        let t2 = item2.lastDone ?? NSDate.distantPast()
                                        return t1.compare(t2) == NSComparisonResult.OrderedAscending
                                        
                                    })
                                    
                                    self.tableView.reloadData()
                                    
                                    self.refresher.endRefreshing()
                                    
                                }
                                
                            } else {
                                
                                UserViewController.displayAlert("Couldn't find last done date", message: error!.description, view: self)
                                
                                self.refresher.endRefreshing()
                            }
                            
                        }
                        
                    }
                    
                    
                    
                } else {
                    
                    UserViewController.displayAlert("Couldn't find chores", message: error!.description, view: self)
                    
                    self.refresher.endRefreshing()
                    
                }
            }
            
        } else {
            
            //Handle if user has null household TODO
            print("User has no household")
            
        }
        
    }
    
    @IBAction func doButtonPressed(sender: AnyObject) {
        
        
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
        return choreList.count
    }
    
    //TODO Modify this cell (maybe new custom cell) to let user EDIT CHORES HERE.  NAME, SCORE, or DELETE ENTIRELY
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: ToDoCell = tableView.dequeueReusableCellWithIdentifier("cell3", forIndexPath: indexPath) as! ToDoCell
        
        let chore = choreList[indexPath.row]
        
        cell.setTableCell(chore.name, score: chore.score, lastDone: chore.lastDone)
        
        cell.tableDoButtonOutlet.tag = indexPath.row
        
        cell.tableDoButtonOutlet.addTarget(self, action: Selector("addActivity:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
        
    }
    
    //Do a chore
    @IBAction func addActivity (sender: UIButton) {
        
        let chore = choreList[sender.tag]
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "M/d"
        
        let dateString = formatter.stringFromDate(NSDate())
        
        let addActivityAlert = UIAlertController(title: "Just making sure", message: "\(User.currentUser()!.username!) did \(chore.name) on \(dateString). This will add \(chore.score) points to their score.", preferredStyle: UIAlertControllerStyle.Alert)
        
        addActivityAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            
            //Nothing happens
            
        }))
        
        addActivityAlert.addAction(UIAlertAction(title: "Yup! Save it", style: .Default, handler: { (action: UIAlertAction!) in
            
            Activity().create(User.currentUser()!, chore: chore, scoreStamp: chore.score, completedAt: NSDate()) { (error, household) -> Void in
                
                if error == nil {
                    
                    chore.updateLastDone() {(error) -> Void in
                        
                        if error != nil {
                            
                            UserViewController.displayAlert("Chore last done date failed to update", message: error!.description, view: self)
                            
                        } else {
                            
                            self.refresh()
                            
                            //Do I need this too?  self.toDoTableView.reloadData()
                            
                        }
                    }
                    
                } else {
                    
                    UserViewController.displayAlert("Activity failed to save", message: error!.description, view: self)
                    
                }
                
            }
                        
        }))
        
        presentViewController(addActivityAlert, animated: true, completion: nil)
        
    }

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        
    }
    

}

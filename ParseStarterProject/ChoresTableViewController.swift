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
    
    var addChoreMode = true
    
    var editedChore = Chore()
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var refresher: UIRefreshControl!
    
    func refresh() {
        
        if let household = User.currentUser()!.household! as? Household {
            
            household.getChores() { (chores: [Chore]?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    self.choreList.removeAll(keepCapacity: true)
                    
                    var foundDates = 0
                    
                    for chore in chores! {
                        
                        if chore.isDeleted == false {
                            
                            self.choreList.append(chore)
                            
                            chore.getLastDone() {(activity: Activity?, error: NSError?) -> Void in
                                
                                if error == nil {
                                    
                                    foundDates++
                                    
                                    //Check to see if all dates have been loaded
                                    if foundDates == self.choreList.count {
                                        
                                        
                                        //Sort so that the ones never done are first
                                        self.choreList.sortInPlace({ (item1, item2) -> Bool in
                                            let t1 = item1.lastDone ?? NSDate.distantPast()
                                            let t2 = item2.lastDone ?? NSDate.distantPast()
                                            return t1.compare(t2) == NSComparisonResult.OrderedAscending
                                            
                                        })
                                        
                                        self.tableView.reloadData()
                                        
                                        self.refresher.endRefreshing()
                                        
                                        self.activityIndicator.stopAnimating()
                                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                        
                                    }
                                    
                                } else {
                                    
                                    UserViewController.displayAlert("Couldn't find last done date", message: error!.localizedDescription, view: self)
                                    
                                    self.refresher.endRefreshing()
                                    
                                    self.activityIndicator.stopAnimating()
                                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                } else {
                    
                    UserViewController.displayAlert("Couldn't find chores", message: error!.localizedDescription, view: self)
                    
                    self.refresher.endRefreshing()
                    
                }
            }
            
        } else {
            
            //Handle if user has null household TODO
            print("User has no household")
            
        }
        
    }
    
    @IBAction func addChore(sender: AnyObject) {
        
        addChoreMode = true

        performSegueWithIdentifier("addEditChore", sender: self)
        
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
        
        loadSpinner()
        
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
                            
                            UserViewController.displayAlert("Chore last done date failed to update", message: error!.localizedDescription, view: self)
                            
                        } else {
                                
                            self.refresh()
                            
                            //Do I need this too?  self.toDoTableView.reloadData()
                            
                        }
                    }
                    
                } else {
                    
                    UserViewController.displayAlert("Activity failed to save", message: error!.localizedDescription, view: self)
                    
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
    func loadSpinner() {
        
        self.activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            let deleteChoreAlert = UIAlertController(title: "Your chore will be deleted", message: "Just making sure you want to delete \(choreList[indexPath.row].name) for everyone in your household.", preferredStyle: UIAlertControllerStyle.Alert)
            
            deleteChoreAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                
                //Nothing happens
                
            }))
            
            deleteChoreAlert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (action: UIAlertAction!) in
                
                self.loadSpinner()
                
                // Delete the row from the data source
                let deletedChore = self.choreList[indexPath.row]

                deletedChore.update(deletedChore.name, score: deletedChore.score, isDeleted: true, closure: {(error) -> Void in
                    
                    if error == nil {
                        
                        self.choreList.removeAtIndex(indexPath.row)
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        
                    } else {
                    
                        UserViewController.displayAlert("Couldn't delete chore", message: error!.localizedDescription, view: self)
                        
                    }
                    
                })
                
            }))
            
            presentViewController(deleteChoreAlert, animated: true, completion: nil)
            
        } else if editingStyle == .Insert {
            
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            
        }    
    }
    
    //Edit a chore
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        addChoreMode = false
        
        editedChore = choreList[indexPath.row]
        
        performSegueWithIdentifier("addEditChore", sender: self)
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "addEditChore" && self.addChoreMode == false {
            
            if let choreViewController = segue.destinationViewController as? ChoreViewController {
                
                choreViewController.addChoreMode = false
                
                choreViewController.editedChore = self.editedChore
                
                choreViewController.choreNameDisplayed = self.editedChore.name
                
                choreViewController.choreScoreDisplayed = self.editedChore.score
                
            }
            
        }

        
    }
    

}

//
//  MembersTableViewController.swift
//  Chore Balance
//
//  Created by Yifan Zhang on 1/17/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class MembersTableViewController: UITableViewController {

    var sortedNames = [String]()
    var sortedScores = [Int]()
    
    var refresher: UIRefreshControl!
    
    func refresh() {
        
        //Clear these
        var sortedNames = [String]()
        var sortedScores = [Int]()
        
        //Find all sorted users in the same household
        MembersTableViewController.getSortedUsers() {(names: [String]?, scores: [Int]?, error: NSError?) -> Void in
            
            if error == nil {
                
                self.sortedNames = names!
                
                self.sortedScores = scores!
                
                self.tableView.reloadData()
                
                self.refresher.endRefreshing()
                
            } else {
                
                if error!.code != 120 {
                    
                    UserViewController.displayAlert("Couldn't load household members", message: error!.localizedDescription, view: self)
                    
                }
           
                self.refresher.endRefreshing()
                
            }
            
        }
        
    }
    
    class func getSortedUsers(closure: ([String]?, [Int]?, NSError?) -> Void) {

        var nameScores = [String:Int]()

        if let household = (User.currentUser()?.household)! as? Household {
        
            household.getUsers() {(users: [PFObject]?, error: NSError?) -> Void in
            
                if error == nil {

                    //For every user in household, sum up scores after scoreFromDate
                    for user in users! {
                    
                        if let parseUser = user as? User {
                            
                            parseUser.getScore() {(score: Int?, scoreError: NSError?) -> Void in
                                
                                if scoreError == nil {
                                    
                                    //Do stuff when we get scores
                                    nameScores[parseUser.username!] = score
                                    
                                    //Check to see if we got all scores - if so, sort and display.
                                    if nameScores.count == users!.count && nameScores.count != 0 {
                                        
                                        var sortedNames = [String]()
                                        var sortedScores = [Int]()
                                        
                                        for (name,score) in (Array(nameScores).sort{$0.1 > $1.1}) {
                                            
                                            sortedNames.append(name)
                                            
                                            sortedScores.append(score)
                                            
                                        }
                                        
                                        closure(sortedNames, sortedScores, nil)
                                        
                                    }
                                    
                                } else {
                                    
                                    closure(nil, nil, scoreError!)
                                    
                                }
                            }
                            
                        } else {
                            
                            print("User downcast failed")
                                
                        }
                    }
                
                } else {
                
                    closure(nil, nil, error!)
                
                }
            
            }
        } else {
            
            print("household downcast fail")
            
        }
        
    }
    
    @IBAction func resetFromDate(sender: AnyObject) {
        
        //Alert to double check the reset
        let resetAlert = UIAlertController(title: "Are you sure?", message: "Just making sure you want to reset all scores in your household.", preferredStyle: UIAlertControllerStyle.Alert)
        
        resetAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            
            //Nothing happens
            
        }))
        
        resetAlert.addAction(UIAlertAction(title: "Reset", style: .Default, handler: { (action: UIAlertAction!) in
            
            //Set the date to calculate scores from to current date
            User.currentUser()?.household?.updateScoreFromDate(NSDate(), closure: { (error) -> Void in
                
                if error == nil {
                    
                    UserViewController.displayAlert("Leaderboard has been reset", message: "Scores will be counted from today onward. Get choring!", view: self)
                    
                    self.refresh()
                    
                } else {
                    
                    UserViewController.displayAlert("Couldn't reset scores", message: error!.localizedDescription, view: self)
                    
                }
                
            })
            
        }))
        
        presentViewController(resetAlert, animated: true, completion: nil)
        
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
        
        //Check if data has been reloaded recently, and if so reload it. TODO
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
        return sortedNames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("memberCell", forIndexPath: indexPath)

        cell.textLabel?.text = sortedNames[indexPath.row]
        
        let score: Int? = sortedScores[indexPath.row]
        
        cell.detailTextLabel?.text = "\(score!)"

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

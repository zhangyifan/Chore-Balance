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
        
        //Find all sorted users in the same household
        MembersTableViewController.getSortedUsers() {(names: [String]?, scores: [Int]?, error: NSError?) -> Void in
            
            if error == nil {
                
                self.sortedNames = names!
                
                self.sortedScores = scores!
                
                self.tableView.reloadData()
                
                self.refresher.endRefreshing()
                
            } else {
                
                UserViewController.displayAlert("Couldn't load household members", message: error!.description, view: self)
                
                self.refresher.endRefreshing()
                
            }
            
        }
        
    }
    
    class func getSortedUsers(closure: ([String]?, [Int]?, NSError?) -> Void) {

        var nameScores = [String:Int]()
        
        //Can I get currentUser as a User rather than PFUser?
        
        //It's the queries that are the problem.  They keep returning PFObjects.
        
        //User.currentUser is a PFUser and that makes its household a PFObject.  Need to correct this logic.  TODO.
        if let household = (User.currentUser()?.household)! as? Household {
        
        household.getUsers() {(users: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {

                //For every user in household, sum up scores
                //In the future set monthly, weekly time limits TODO
                for user in users! {
                    
                    let parseUser = user as! User
                    
                    //let parseHousehold = parseUser["household"] as! Household
                    
                    //let customUser = User(name: parseUser.username!, password: "randomPassword", household: Household(name: parseHousehold["name"] as! String))
                    
                    parseUser.getScore() {(score: Int?, error: NSError?) -> Void in
                        
                        if error == nil {
                            
                            //Do stuff when we get scores
                            nameScores[parseUser.username!] = score
                            
                            //Check to see if we got all scores - if so, sort and display.
                            if nameScores.count == users!.count {
                                
                                var sortedNames = [String]()
                                var sortedScores = [Int]()
                                
                                for (name,score) in (Array(nameScores).sort{$0.1 > $1.1}) {
                                    
                                    sortedNames.append(name)
                                    
                                    sortedScores.append(score)
                                    
                                }
                                
                                closure(sortedNames, sortedScores, nil)
                                
                            }
                            
                        } else {
                            
                            
                            
                        }
                        
                
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

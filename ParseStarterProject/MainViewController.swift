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

//List of users in household.  Maybe cache in the future?  TODO GET RID OF THIS?
var userList = [User]()

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var toDoTableView: UITableView!
    
    @IBOutlet var balanceImage: UIImageView!
    
    //Animate the balance
    var balanceTimer = NSTimer()
    var animationCounter = 1
    var countingUp = true
    var balanceAnimating = true
    
    //Animate the member names
    var namesTimer = NSTimer()

    @IBOutlet var winnerName: UILabel!
    @IBOutlet var winnerScore: UILabel!
    @IBOutlet var secondName: UILabel!
    @IBOutlet var secondScore: UILabel!
    @IBOutlet var secondToLastName: UILabel!
    @IBOutlet var secondToLastScore: UILabel!
    @IBOutlet var lastName: UILabel!
    @IBOutlet var lastScore: UILabel!
    
    /*#############Uncomment when ready to work on this
    @IBOutlet var activityTableView: UITableView!
    
    //Activities section
    var activityList = [Activity]() ##########*/
    
    //Chores section
    var choreList = [Chore]()

    //Refresh function
    var lastRefreshTime = NSDate()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        lastRefreshTime = NSDate()
        
        //***********ANIMATIONS SETUP***************
        winnerName.alpha = 0
        winnerScore.alpha = 0
        secondName.alpha = 0
        secondScore.alpha = 0
        secondToLastName.alpha = 0
        secondToLastScore.alpha = 0
        lastName.alpha = 0
        lastScore.alpha = 0

        winnerName.center.y = 42.5
        winnerScore.center.y = 69.5
        secondName.center.y = 63
        secondScore.center.y = 82
        secondToLastName.center.y = 74
        secondToLastScore.center.y = 93
        lastName.center.y = 84
        lastScore.center.y = 103

        balanceTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("startAnimation"), userInfo: nil, repeats: true)
        
        if User.currentUser() != nil {
            
            //********CURRENT SCORES SECTION**************
            
            //Find all sorted users in the same household
            MembersTableViewController.getSortedUsers() {(names: [String]?, scores: [Int]?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    if names!.count > 0 && scores!.count > 0 {
                        
                        self.winnerName.text = names![0]
                        self.winnerScore.text = String(scores![0])
                        
                        self.lastName.text = ""
                        self.lastScore.text = ""
                        self.secondName.text = ""
                        self.secondScore.text = ""
                        self.secondToLastName.text = ""
                        self.secondToLastScore.text = ""
                        
                        if names!.count == 2 && scores!.count == 2 {
                            
                            self.lastName.text = names![1]
                            self.lastScore.text = String(scores![1])
                            
                        } else if names!.count == 3 && scores!.count == 3 {
                            
                            self.lastName.text = names![2]
                            self.lastScore.text = String(scores![2])
                            self.secondName.text = names![1]
                            self.secondScore.text = String(scores![1])
                            
                        } else {
                            
                            let lastNameIndex = names!.count - 1
                            let lastScoreIndex = scores!.count - 1
                            let secondToLastNameIndex = names!.count - 2
                            let secondToLastScoreIndex = scores!.count - 2
                            
                            self.lastName.text = names![lastNameIndex]
                            self.lastScore.text = String(scores![lastScoreIndex])
                            self.secondName.text = names![1]
                            self.secondScore.text = String(scores![1])
                            self.secondToLastName.text = names![secondToLastNameIndex]
                            self.secondToLastScore.text = String(scores![secondToLastScoreIndex])
                            
                        }
                        
                    }

                    refreshControl.endRefreshing()
                    
                } else {
                    
                    UserViewController.displayAlert("Couldn't load household members", message: error!.localizedDescription, view: self)

                    refreshControl.endRefreshing()
                    
                }
                
            }
            
            if let household = User.currentUser()!.household! as? Household {
                
                /*#############*******ACTIVITY FEED SECTION**************
                household.getActivities() {(activities: [Activity]?, error: NSError?)-> Void in
                
                    if error == nil {
                    
                        self.activityList = activities!
                    
                        self.activityTableView.reloadData()
                    
                    } else {
                    
                        UserViewController.displayAlert("Couldn't find activities", message: error!.localizedDescription, view: self)
                    
                        refreshControl.endRefreshing()
                    
                    }
                }###############*/
                
                //********CHORES SECTION**************
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
                                            
                                            self.toDoTableView.reloadData()
                                            
                                            self.balanceAnimating = false
                                            self.refreshControl.endRefreshing()
                                            
                                        }
                                        
                                    } else {
                                        
                                        UserViewController.displayAlert("Couldn't find last done date", message: error!.localizedDescription, view: self)
                                        
                                        self.balanceAnimating = false
                                        self.refreshControl.endRefreshing()
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    } else {
                        
                        UserViewController.displayAlert("Couldn't find chores", message: error!.localizedDescription, view: self)
                        
                        self.balanceAnimating = false
                        refreshControl.endRefreshing()
    
                    }
                }
                
            } else {
                
                //Handle if user has no household TODO
                print("User has no household")
                
            }
            
        } else {
            
            //catch and make user login again TODO
            print("no current user logged in")
            
        }
        
        //Maybe in the future have caching of data?
        
        
    }
    
    //Start balance going up and down, ending in up position
    func startAnimation() {
            
        if countingUp == true {
            
            if animationCounter == 13 {
                
                if balanceAnimating {
                    
                    countingUp = false
                    
                } else {
                    
                    balanceTimer.invalidate()
                    
                    balanceAnimating = true

                    displayNames()
                }
           
            } else {
                
                animationCounter++
                
            }
            
        } else {
            
            if animationCounter == 1 {
                
                countingUp = true
                
            } else {
                
                animationCounter--
                
            }
            
        }
        
        balanceImage.image = UIImage(named: "frame\(animationCounter).png")
    }
    
    //Names appear with fade-in
    func displayNames() {
        
        UIView.animateWithDuration(1, animations: { () -> Void in
            
            self.winnerName.alpha = 1
            self.winnerScore.alpha = 1
            self.secondName.alpha = 1
            self.secondScore.alpha = 1
            self.secondToLastName.alpha = 1
            self.secondToLastScore.alpha = 1
            self.lastName.alpha = 1
            self.lastScore.alpha = 1
            
            self.namesTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("animateBalanceDown"), userInfo: nil, repeats: true)

        })
        
        self.animateNames()
        
    }
    
    func animateNames() {
        
        //In the future consider a delay, or completion block to displayNames? TODO
        
        UIView.animateWithDuration(1.3) { () -> Void in
            
            self.winnerName.center.y = self.winnerName.center.y+30
            self.winnerScore.center.y = self.winnerScore.center.y+30
            self.secondName.center.y = self.secondName.center.y+10
            self.secondScore.center.y = self.secondScore.center.y+10
            self.secondToLastName.center.y = self.secondToLastName.center.y-10
            self.secondToLastScore.center.y = self.secondToLastScore.center.y-10
            self.lastName.center.y = self.lastName.center.y-30
            self.lastScore.center.y = self.lastScore.center.y-30
            
        }
        
    }
    
    func animateBalanceDown() {
        
        if animationCounter > 1 {
                
            animationCounter--
                
        } else {
            
            namesTimer.invalidate()
            
        }
            
        balanceImage.image = UIImage(named: "frame\(animationCounter).png")

    }
    
    @IBAction func logOut(sender: AnyObject) {
        
        let addActivityAlert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.Alert)
        
        addActivityAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            
            //Nothing happens
            
        }))
        
        addActivityAlert.addAction(UIAlertAction(title: "Logout", style: .Default, handler: { (action: UIAlertAction!) in
            
            PFUser.logOut()
            
            self.performSegueWithIdentifier("logoutFromMain", sender: nil)
            
        }))
        
        presentViewController(addActivityAlert, animated: true, completion: nil)
        
    }
    
    //Share
    @IBAction func shareButton(sender: AnyObject) {
        
        let shareText = "I think this Chore Balance app can help us get chores done without nagging.  Can you download it and join the household I made - \(User.currentUser()!.household!.name)?"
        
        let shareURL = NSURL(string: "http://bit.ly/areallink")
        
        let activityViewController = UIActivityViewController(activityItems: [shareText, shareURL!], applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [UIActivityTypePostToFacebook, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo]
        
        presentViewController(activityViewController, animated: true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Pull to refresh
        self.scrollView.addSubview(self.refreshControl)
        
    }
    
    //Prep for animations because view has coordinates but not appeared yet
    override func viewDidLayoutSubviews() {
    
        winnerName.alpha = 0
        winnerScore.alpha = 0
        secondName.alpha = 0
        secondScore.alpha = 0
        secondToLastName.alpha = 0
        secondToLastScore.alpha = 0
        lastName.alpha = 0
        lastScore.alpha = 0
    }
    
    //Hide Navigation Controller Back button and special color for main screen
    override func viewWillAppear(animated: Bool) {
        
        self.navigationItem.hidesBackButton = true
        //self.navigationController!.navigationBar.hidden = true
        
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 247.0/255.0, green: 252.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        //self.navigationController!.navigationBar.translucent = true
        //self.navigationController!.navigationBar.alpha = 0.5
        
        //Remove line beneath navigation bars
        self.navigationController?.navigationBar.clipsToBounds = true
        
        //Check if data has been reloaded recently, and if so reload it. TODO
        handleRefresh(refreshControl)
        
        //Set up tables and stuff
        toDoTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "toDoCell")
        //###########activityTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "activityCell")
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count:Int?
        
        if tableView == self.toDoTableView {
            
            //Calculate rows of Chores
            count = choreList.count
            
        }
        
        /*#######if tableView == self.activityTableView {
            
            //Calculate rows of activities
            count = activityList.count
        }###### */
        
        return count!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell?
        
        if tableView == self.toDoTableView {
            
            let toDoCell: ToDoCell = tableView.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath) as! ToDoCell
            
            let chore = choreList[indexPath.row]
            
            toDoCell.setCell(chore.name, score: chore.score, lastDone: chore.lastDone)
            
            toDoCell.doButtonOutlet.tag = indexPath.row
            
            toDoCell.doButtonOutlet.addTarget(self, action: Selector("addActivity:"), forControlEvents: UIControlEvents.TouchUpInside)
            
            cell = toDoCell
            
        }
        
        /*###########if tableView == self.activityTableView {
            
            let activityCell: ActivityCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ActivityCell
            
            let activity = activityList[indexPath.row]
            
            let completedDate = activity.completedAt
            
            let choreName = activity.chore["name"] as! String
            
            let userName = activity.user["username"] as! String
            
            let description = userName + " did " + choreName
            
            let score = activity.scoreStamp
            
            activityCell.setCell(completedDate, description: description, score: score)
            
            cell = activityCell
        }##########*/
        
        
        return cell!
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
                            
                            self.handleRefresh(self.refreshControl)
                            
                        }
                    }
                    
                } else {
                    
                    UserViewController.displayAlert("Activity failed to save", message: error!.localizedDescription, view: self)
                    
                }
                
            }
                    
        }))
        
        presentViewController(addActivityAlert, animated: true, completion: nil)
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == self.toDoTableView {
            
            self.performSegueWithIdentifier("showChores", sender: self)
            
        }
        
        /*##########if tableView == self.activityTableView {
            
            self.performSegueWithIdentifier("showActivityFeed", sender: self)
            
        }###########*/
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation - how to do this to pass list of users?

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        if (segue.identifier == "logoutFromMain")
        {
            if let userViewController = segue.destinationViewController as? UserViewController {

                userViewController.signUpActive = false;
            }
            
        }
    }
    

}

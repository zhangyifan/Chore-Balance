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

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
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
    
    var isTie = false
    
    //Activities section
    var activityList = [Activity]()
    
    @IBOutlet var collectionView: UICollectionView!
    
    var tickerTimer = NSTimer()
    
    //Chores section
    var choreList = [Chore]()
    
    var addChoreMode = true
    
    var editedChore = Chore()

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
        balanceTimer.invalidate()
        namesTimer.invalidate()
        
        winnerName.alpha = 0
        winnerScore.alpha = 0
        secondName.alpha = 0
        secondScore.alpha = 0
        secondToLastName.alpha = 0
        secondToLastScore.alpha = 0
        lastName.alpha = 0
        lastScore.alpha = 0
        print("refresh \(winnerName.alpha)")

        winnerName.center.y = 42.5
        winnerScore.center.y = 69.5
        secondName.center.y = 63
        secondScore.center.y = 82
        secondToLastName.center.y = 74
        secondToLastScore.center.y = 93
        lastName.center.y = 84
        lastScore.center.y = 103

        balanceTimer = NSTimer.scheduledTimerWithTimeInterval(0.03, target: self, selector: Selector("startAnimation"), userInfo: nil, repeats: true)
        
        if User.currentUser() != nil {

            //********CURRENT SCORES SECTION**************
            
            //Find all sorted users in the same household
            MembersTableViewController.getSortedUsers() {(names: [String]?, scores: [Int]?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    if names!.count > 0 && scores!.count > 0 {
                        
                        self.isTie = self.checkForTie(scores!)
                        print("check for tie \(self.isTie)")
                        
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
                            
                        } else if names!.count > 3 {
                            
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
                    
                    self.balanceAnimating = false

                    refreshControl.endRefreshing()
                    
                } else {
                    
                    UserViewController.displayAlert("Couldn't load household members", message: error!.localizedDescription, view: self)
                    
                    self.balanceAnimating = false

                    refreshControl.endRefreshing()
                    
                }
                
            }
            
            if let household = User.currentUser()!.household! as? Household {
                
                let myCalendar = NSCalendar.currentCalendar()
                //let yesterday =
                let threeDaysAgo = myCalendar.dateByAddingUnit(.Day, value: -3, toDate: NSDate(), options: [])
                
                //********ACTIVITY FEED SECTION**************
                household.getActivities(threeDaysAgo) {(activities: [Activity]?, error: NSError?)-> Void in
                
                    if error == nil {
                    
                        self.activityList = activities!
                    
                        self.collectionView.reloadData()

                    } else {
                    
                        UserViewController.displayAlert("Couldn't find activities", message: error!.localizedDescription, view: self)
                    
                        refreshControl.endRefreshing()
                    
                    }
                }
                
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

                                            self.refreshControl.endRefreshing()
                                            
                                        }
                                        
                                    } else {
                                        
                                        UserViewController.displayAlert("Couldn't find last done date", message: error!.localizedDescription, view: self)
                                        
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
    
    //Check to see if there's a tie in scores
    func checkForTie(scores: [Int]) -> Bool {
        
        var isTie = true
        
        let firstScore = scores[0]
        
        for score in scores {
            
            if score != firstScore {
                
                isTie = false
            }
            
        }
        
        return isTie
    }
    
    //Start balance going up and down, ending in up position
    func startAnimation() {
            
        if countingUp == true {
            
            if animationCounter == 14 {
                
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
        
        print("start animation \(animationCounter)")
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
            print("display names")
            

        })
        
        if isTie {
            
            namesTimer = NSTimer.scheduledTimerWithTimeInterval(0.075, target: self, selector: Selector("animateBalanceTied"), userInfo: nil, repeats: true)
            
            animateTiedNames()
            
        } else {
            
            namesTimer = NSTimer.scheduledTimerWithTimeInterval(0.075, target: self, selector: Selector("animateBalanceDown"), userInfo: nil, repeats: true)
            
            animateNames()
        }
        
        
    }
    
    func animateNames() {
        
        //In the future consider a delay, or completion block to displayNames? TODO
        
        UIView.animateWithDuration(1.2) { () -> Void in
            
            self.winnerName.center.y = self.winnerName.center.y+30
            self.winnerScore.center.y = self.winnerScore.center.y+30
            self.secondName.center.y = self.secondName.center.y+10
            self.secondScore.center.y = self.secondScore.center.y+10
            self.secondToLastName.center.y = self.secondToLastName.center.y-10
            self.secondToLastScore.center.y = self.secondToLastScore.center.y-10
            self.lastName.center.y = self.lastName.center.y-30
            self.lastScore.center.y = self.lastScore.center.y-30
            print("animate names")
            
        }
        
    }
    
    func animateTiedNames() {
  
        UIView.animateWithDuration(0.65) { () -> Void in
            
            self.winnerName.center.y = self.winnerName.center.y+18
            self.winnerScore.center.y = self.winnerScore.center.y+18
            self.secondName.center.y = self.secondName.center.y+9
            self.secondScore.center.y = self.secondScore.center.y+9
            self.secondToLastName.center.y = self.secondToLastName.center.y-2
            self.secondToLastScore.center.y = self.secondToLastScore.center.y-2
            self.lastName.center.y = self.lastName.center.y-12
            self.lastScore.center.y = self.lastScore.center.y-12
            print("animate names")
            
        }
        
        /*self.secondName.font = UIFont.boldSystemFontOfSize(24)
        self.secondScore.font = UIFont.boldSystemFontOfSize(24)
        self.secondToLastName.font = UIFont.boldSystemFontOfSize(24)
        self.secondToLastScore.font = UIFont.boldSystemFontOfSize(24)
        self.lastName.font = UIFont.boldSystemFontOfSize(24)
        self.lastScore.font = UIFont.boldSystemFontOfSize(24)*/
        
    }
    
    func animateBalanceDown() {
        
        if animationCounter > 1 {
                
            animationCounter--
                
        } else {
            
            namesTimer.invalidate()
            
        }
        print("balance down \(animationCounter)")
        balanceImage.image = UIImage(named: "frame\(animationCounter).png")

    }
    
    func animateBalanceTied() {
        
        if animationCounter > 8 {
            
            animationCounter--
            
        } else {
            
            namesTimer.invalidate()
            
        }
        print("balance tied \(animationCounter)")
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

        self.tickerTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("autoScroll"), userInfo: nil, repeats: true)
        
    }
    
    //Disappear labels when rotated because will be in wrong place
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        winnerName.alpha = 0
        winnerScore.alpha = 0
        secondName.alpha = 0
        secondScore.alpha = 0
        secondToLastName.alpha = 0
        secondToLastScore.alpha = 0
        lastName.alpha = 0
        lastScore.alpha = 0
        print("will rotate \(winnerName.alpha)")
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
    
    //Activity ticker collection view
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return activityList.count
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let collectionViewWidth = self.collectionView.bounds.size.width
        return CGSize(width: collectionViewWidth, height: 48)
    
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: TickerCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell3", forIndexPath: indexPath) as! TickerCell
        
        // Set cell width to 100%
        let collectionViewWidth = self.collectionView.bounds.size.width
        cell.frame.size.width = collectionViewWidth
        
        let activity = activityList[indexPath.row]
        
        let completedDate = activity.completedAt
        
        let choreName = activity.chore["name"] as! String
        
        let userName = activity.user["username"] as! String
        
        let description = userName + " did " + choreName
        
        let score = activity.scoreStamp
        
        cell.setCell(completedDate, description: description, score: score)
        
        return cell
        
    }
    
    //Tap on ticker
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        self.performSegueWithIdentifier("showActivityFeed", sender: self)
  
    }
    
    func autoScroll() {
        
        if activityList != [] {
            
            if activityList.count > (self.collectionView.indexPathsForVisibleItems()[0].row + 1){
                
                let nextIndex = NSIndexPath(forItem: self.collectionView.indexPathsForVisibleItems()[0].row + 1, inSection: 0)
                
                self.collectionView.scrollToItemAtIndexPath(nextIndex, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
                
            } else {
                
                let firstIndex = NSIndexPath(forItem: 0, inSection: 0)
                
                self.collectionView.scrollToItemAtIndexPath(firstIndex, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
                
            }
            
        }
        
    }
    
    //Chores Tabe
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return choreList.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let toDoCell: ToDoCell = tableView.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath) as! ToDoCell
        
        if choreList.count > indexPath.row {
       
            let chore = choreList[indexPath.row]
                
            toDoCell.setCell(chore.name, score: chore.score, lastDone: chore.lastDone)
                
            toDoCell.doButtonOutlet.tag = indexPath.row
            
            toDoCell.doButtonOutlet.addTarget(self, action: Selector("addActivity:"), forControlEvents: UIControlEvents.TouchUpInside)
                
        } else {
            
            toDoCell.addChoreCell()
            
            toDoCell.addChoreButton.addTarget(self, action: Selector("addChore:"), forControlEvents: UIControlEvents.TouchUpInside)
                
        }
        
        return toDoCell
  
    }
    
    //Add a chore
    @IBAction func addChore (sender: UIButton) {
        
        addChoreMode = true
        
        performSegueWithIdentifier("addEditChore", sender: self)
        
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
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if choreList.count > indexPath.row {
            
            addChoreMode = false
            
            editedChore = choreList[indexPath.row]
            
            performSegueWithIdentifier("addEditChore", sender: self)
            
        } else {
            
            addChoreMode = true
            
            performSegueWithIdentifier("addEditChore", sender: self)

        }

    }
    
    //A thinking spinner
    func loadSpinner() {
        
        self.activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation - how to do this to pass list of users?

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "logoutFromMain" {
            
            if let userViewController = segue.destinationViewController as? UserViewController {

                userViewController.signUpActive = false;
            }
            
        } else if segue.identifier == "addEditChore" && self.addChoreMode == false {
            
            // Get the new view controller using segue.destinationViewController.
            if let choreViewController = segue.destinationViewController as? ChoreViewController {
                
                choreViewController.addChoreMode = false
                
                choreViewController.editedChore = self.editedChore
                
                choreViewController.choreNameDisplayed = self.editedChore.name
                
                choreViewController.choreScoreDisplayed = self.editedChore.score
                
            }
            
        }
    }
    

}

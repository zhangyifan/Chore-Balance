//
//  ChoreViewController.swift
//  Chore Balance
//
//  Created by Yifan Zhang on 1/14/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class ChoreViewController: UIViewController, UITableViewDelegate {

    //In the future can make the height of the table adjust with number of cells
    
    //TODO - make Next/Done top right bar buttons do the same thing as buttons below
    
    //Use for both signup and adding more chores
    //var signupMode = true
    
    @IBOutlet var choreNameField: UITextField!
    
    @IBOutlet var scoreInput: UISegmentedControl!
    
    @IBAction func doneButton(sender: AnyObject) {
        
        if choreNameField == "" {
            
            UserViewController.displayAlert("Chore name missing", message: "Please enter a name for your chore", view: self)
            
        } else if scoreInput == nil {
            
            UserViewController.displayAlert("Score missing", message: "Please choose a score for your chore", view: self)
            
        } else {
            
            if PFUser.currentUser() != nil {
                
                var score = 1
                
                switch scoreInput.selectedSegmentIndex {
                    
                case 0:
                    score = 1
                case 1:
                    score = 3
                case 2:
                    score = 5
                default:
                    break;
                }
                
                Chore().create(choreNameField.text!, score: score, household: User.currentUser()!.household! as! Household, lastDone: nil) {(error, chore) -> Void in
                    
                    if error == nil {
                        
                        //Add this as an activity - comment this out later if not needed.  For sample data, double to test weeding out duplicate chores.
                        Activity(user: User.currentUser()!, chore: chore, scoreStamp: chore.score, completedAt: NSDate())
                        Activity(user: User.currentUser()!, chore: chore, scoreStamp: chore.score, completedAt: NSDate())
                        
                        self.performSegueWithIdentifier("choreSaved", sender: self)
                        
                    } else {
                        
                        UserViewController.displayAlert("Chore failed to save", message: error!.description, view: self)
                        
                    }
                }
                
            } else {
                
                UserViewController.displayAlert("You're not logged in", message: "Please log in to add a chore", view: self)
                
            }
            
        }
        
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /*For later when I make this a table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //Can adjust number of rows in adding chores
        return 3
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        
        return cell
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }*/
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  ChoreViewController.swift
//  Chore Balance
//
//  Created by Yifan Zhang on 1/14/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class ChoreViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate {

    //In the future can make the height of the table adjust with number of cells
    
    //TODO - make Next/Done top right bar buttons do the same thing as buttons below
    
    var addChoreMode = true
    
    var editedChore = Chore()
    
    var choreNameDisplayed = ""
    
    var choreScoreDisplayed = 0
    
    @IBOutlet var instructionLabel: UILabel!
    
    @IBOutlet var choreNameField: UITextField!
    
    @IBOutlet var scoreInput: UISegmentedControl!
    
    @IBAction func doneButton(sender: AnyObject) {
        
        if choreNameField.text == "" {
            
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
                
                if addChoreMode == true {
   
                    Chore().create(choreNameField.text!, score: score, household: User.currentUser()!.household! as! Household, lastDone: nil) {(error, chore) -> Void in
                        
                        if error == nil {
                            
                            /*//Add this as an activity - comment this out later if not needed.  For sample data, double to test weeding out duplicate chores.
                            Activity(user: User.currentUser()!, chore: chore, scoreStamp: chore.score, completedAt: NSDate())
                            Activity(user: User.currentUser()!, chore: chore, scoreStamp: chore.score, completedAt: NSDate())*/
                            
                            self.performSegueWithIdentifier("choreSaved", sender: self)
                            
                        } else {
                            
                            UserViewController.displayAlert("Chore failed to save", message: error!.localizedDescription, view: self)
                            
                        }
                    }
                
                } else {
                    
                    //Edit an existing chore
                    editedChore.update(choreNameField.text!, score: score, isDeleted: false, closure: { (error) -> Void in
                        
                        if error == nil {
                            
                            let savedChoreAlert = UIAlertController(title: "All done!", message: "Your edits have been saved.", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            savedChoreAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                                
                                self.navigationController?.popViewControllerAnimated(true)
                                
                            }))
                            
                            self.presentViewController(savedChoreAlert, animated: true, completion: nil)
                            
                        } else {
                            
                             UserViewController.displayAlert("Edited chore failed to save", message: error!.localizedDescription, view: self)
                            
                        }
                        
                    })
                    
                }
                
                
            } else {
                
                UserViewController.displayAlert("You're not logged in", message: "Please log in to add a chore", view: self)
                
            }
            
        }
        
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.choreNameField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        
        setLabels()

        self.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBarHidden = false
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 132.0/255.0, green: 220.0/255.0, blue: 154.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.alpha = 1.0
        self.navigationController?.navigationBar.clipsToBounds = false
        
    }
    
    func setLabels() {
        
        if addChoreMode == true {
            
            self.title = "Add Chores"
            
            instructionLabel.text = "Add chores that need to be done regularly, and mark whether they are small (1), medium (3) or large (5) tasks."
            
            scoreInput.selectedSegmentIndex = 0
            
        } else {
            
            //Edit chore mode
            
            self.title = "Edit Chore"
            
            instructionLabel.text = "Edit your chore's name or score."
            
            choreNameField.text = choreNameDisplayed
            
            switch choreScoreDisplayed {
                
            case 1:
                scoreInput.selectedSegmentIndex = 0
                
            case 3:
                scoreInput.selectedSegmentIndex = 1
                
            case 5:
                scoreInput.selectedSegmentIndex = 2
            
            default:
                break;
                
            }
            
        }
        
    }
    
    //Add these two functions for allowing keyboard to close when you touch outside (#1) and hit return (#2)
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        doneButton("")
        
        return true
        
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

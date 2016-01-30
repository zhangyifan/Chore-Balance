//
//  HouseholdViewController.swift
//  Chore Balance
//
//  Created by Yifan Zhang on 1/12/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

//TODO direct user to login screen if they are not logged in

class HouseholdViewController: UIViewController {

    @IBOutlet var householdTextField: UITextField!
    
    @IBOutlet var smallText: UILabel!
    
    @IBOutlet var mainButtonText: UIButton!
    
    @IBOutlet var smallButton: UIButton!
    
    var signUpActive = true
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    @IBAction func householdSignup(sender: AnyObject) {
        
        if householdTextField.text == "" {
        
            UserViewController.displayAlert("No household name", message: "Please enter a household name", view: self)
            
        } else {
            
            //Load spinner
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            if let user = PFUser.currentUser() {
                
                //Search for existing households with this name
                let householdQuery = Household.query()!
                householdQuery.whereKey("name", equalTo: householdTextField.text!)
                
                householdQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if error != nil {
                            
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            
                        UserViewController.displayAlert("Household name error", message: error!.localizedDescription, view: self)
                        
                    } else {
                        
                        //Create household mode
                        if self.signUpActive == true {
                            
                            if objects!.count > 0 {
                                
                                self.activityIndicator.stopAnimating()
                                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                
                                UserViewController.displayAlert("Household name already exists", message: "Please choose a different one or join it", view: self)
                                
                            } else if objects!.count == 0 {
                                
                                Household().create(self.householdTextField.text!) {(error, household) -> Void in
                                    
                                    if error == nil {
                                        
                                        //Assumes create household view is only shown to new users.  Might want to add check later in case user already has a household TODO
                                        self.updateUserHousehold(household, user: user)
                                        
                                    } else {
                                        
                                        self.activityIndicator.stopAnimating()
                                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                        
                                        UserViewController.displayAlert("Household failed to save", message: error!.localizedDescription, view: self)
                                        
                                    }
                                }
                                
                            }
                            
                        //Join household mode
                        } else {
                            
                            if objects!.count > 1 {
                                
                                self.activityIndicator.stopAnimating()
                                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                
                                UserViewController.displayAlert("More than one household has that name", message: "Please notify app developer", view: self)
                                
                            } else if objects!.count < 1 {
                                
                                self.activityIndicator.stopAnimating()
                                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                
                                UserViewController.displayAlert("No households with that name", message: "Check your spelling or create a household", view: self)
                                
                            } else {
                                
                                for object in objects! {
                                    
                                    self.updateUserHousehold(object as! Household, user: user)
                                    
                                }
                                
                            }

                        }
                        
                    }
                    
                })
                
            } else {
                
                //Error with user logged in
                UserViewController.displayAlert("You're not logged in", message: "Please login or signup to add a household", view: self)
                
                //self.navigationController?.pushViewController(userViewController, animated: true)
                
            }
            
        }
        
    }
    
    //A function to add household to a user, once they create/join it.  Maybe should move it to User object?  TODO
    func updateUserHousehold(household: Household, user: PFUser) {
        
        user["household"] = household
        
        user.saveInBackgroundWithBlock({ (userSuccess, error) -> Void in
            
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            if(userSuccess) {
                
                self.performSegueWithIdentifier("householdSaved", sender: self)
                
            } else {
                
                UserViewController.displayAlert("Failed to add you to household", message: error!.localizedDescription, view: self)
                
            }
            
        })
        
    }
    
    @IBAction func smallButtonTap(sender: AnyObject) {
        
        if signUpActive == true {
            
            //Switch screen to login mode
            householdTextField.placeholder = "Enter the exact household name to join it"
            mainButtonText.setTitle("Join", forState: UIControlState.Normal)
            smallText.text = "Creating a household?"
            smallButton.setTitle("Tap here", forState: UIControlState.Normal)
            
            signUpActive = false
            
        } else {
            
            //Switch screen to signup mode
            householdTextField.placeholder = "Get creative! (i.e. The Incredible Smiths)"
            mainButtonText.setTitle("Create", forState: UIControlState.Normal)
            smallText.text = "Joining a household?"
            smallButton.setTitle("Enter here", forState: UIControlState.Normal)
            
            signUpActive = true
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class UserViewController: UIViewController, UITextFieldDelegate {
    
    var signUpActive = true
    
    //Generic Error Message
    var errorMessage = "Something went wrong. Please try again later."

    @IBOutlet var username: UITextField!
    
    @IBOutlet var password: UITextField!
    
    @IBOutlet var mainButtonText: UIButton!
    
    @IBOutlet var registeredText: UILabel!
    
    @IBOutlet var smallButtonText: UIButton!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    //This function used across the app
    class func displayAlert(title: String, message: String, view: UIViewController) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
            
        }))
        
        view.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func mainButtonTap(sender: AnyObject) {
        
        //Check for blank username and password
        if username.text == "" || password.text == "" {
            
            UserViewController.displayAlert("Oops!", message: "Please enter a username and password", view: self)
            
        //Actually sign user up
        } else {
            
            //Load spinner
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            //Signup mode
            if signUpActive == true {
                
                User().signUp(username.text!, password: password.text!) {(error: NSError?)-> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if error == nil {
                        
                        //Signup successful
                        self.performSegueWithIdentifier("signedUp", sender: self)
                        
                    } else {
                        
                        UserViewController.displayAlert("Signup Failed", message: error!.userInfo["error"] as! String, view: self)
                    }
                }
                
                
            //Login mode
            } else {
                
                User().logIn(username.text!, password: password.text!) {(user: PFUser?, error: NSError?) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if user != nil {
                        
                        //Logged in
                        if let household = user!["household"] {
                            
                            self.performSegueWithIdentifier("loggedIn", sender: self)
                            
                        } else {
                            
                            self.performSegueWithIdentifier("signedUp", sender: self)
                            
                        }
                        
                    } else {
                        
                        UserViewController.displayAlert("Login Failed", message: error!.userInfo["error"] as! String, view: self)
                        
                    }
                }
            }
            
        }

    }
    
    @IBAction func smallButtonTap(sender: AnyObject) {
        
        if signUpActive == true {
            
            signUpActive = false
            
        } else {
            
            signUpActive = true
            
        }
        
        setLabels()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.username.delegate = self
        self.password.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //Check if user is already loggedin after screen shows up. Not sure if it's helpful
        let user = User.currentUser()
        if user?.objectId != nil {
            
            if let household = user!.household {
                
                self.performSegueWithIdentifier("loggedIn", sender: self)
                
            } else {
                
                self.performSegueWithIdentifier("signedUp", sender: self)
                
            }
            
        } 
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        setLabels()
        
        self.navigationController?.navigationBarHidden = false
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 132.0/255.0, green: 220.0/255.0, blue: 154.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.alpha = 1.0
        self.navigationController?.navigationBar.clipsToBounds = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setLabels() {
        
        if signUpActive == true {
            
            //Set screen into signup mode
            mainButtonText.setTitle("Sign Up", forState: UIControlState.Normal)
            registeredText.text = "Already have an account?"
            smallButtonText.setTitle("Login", forState: UIControlState.Normal)
            
        } else {
            
            //Set screen into login mode
            mainButtonText.setTitle("Log In", forState: UIControlState.Normal)
            registeredText.text = "Don't have an account?"
            smallButtonText.setTitle("Signup", forState: UIControlState.Normal)
            
            self.navigationItem.hidesBackButton = true

            
        }
        
    }
    
    //Add these two functions for allowing keyboard to close when you touch outside (#1) and hit return (#2)
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        mainButtonTap("")
        
        return true
        
    }
}

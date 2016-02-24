//
//  InviteViewController.swift
//  Chore Balance
//
//  Created by Yifan Zhang on 1/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class InviteViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var emailField: UITextField!
    
    var shareText = ""
    
    //let shareURL = NSURL(string: "http://bit.ly/areallink")
    
    @IBAction func sendInvite(sender: AnyObject) {
        
        User.currentUser()!.household!.fetchIfNeededInBackgroundWithBlock { (household, error) -> Void in
            
            if let householdName = (User.currentUser()!.household!.name) as? String {
                
                self.shareText = "I think this Chore Balance app can help us get chores done without nagging.  Can you download it and join the household I made - \(householdName)?"
                
            }
     
            if self.emailField.text != "" {
                
                let newShareText = "Hey \(self.emailField.text!), " + self.shareText
                
                let activityViewController = UIActivityViewController(activityItems: [newShareText], applicationActivities: nil)
                
                //let activityViewController = UIActivityViewController(activityItems: [newShareText, self.shareURL!], applicationActivities: nil)
                
                activityViewController.excludedActivityTypes = [UIActivityTypePostToFacebook, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo]
                
                self.presentViewController(activityViewController, animated: true, completion: nil)
                
            } else {
                
                //let activityViewController = UIActivityViewController(activityItems: [self.shareText, self.shareURL!], applicationActivities: nil)
                
                let activityViewController = UIActivityViewController(activityItems: [self.shareText], applicationActivities: nil)
                
                activityViewController.excludedActivityTypes = [UIActivityTypePostToFacebook, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo]
                
                self.presentViewController(activityViewController, animated: true, completion: nil)
                
            }
            
            
        }
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.emailField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Add these two functions for allowing keyboard to close when you touch outside (#1) and hit return (#2)
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        sendInvite("")
        
        return true
        
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

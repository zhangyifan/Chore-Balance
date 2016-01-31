//
//  InviteViewController.swift
//  Chore Balance
//
//  Created by Yifan Zhang on 1/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class InviteViewController: UIViewController {

    @IBOutlet var emailField: UITextField!
    
    let shareText = "I think this Chore Balance app can help us get chores done without nagging.  Can you download it and join the household I made - \(User.currentUser()!.household!.name)?"
    
    let shareURL = NSURL(string: "http://bit.ly/areallink")
    
    @IBAction func sendInvite(sender: AnyObject) {
        
        if emailField.text != "" {
            
            let newShareText = "Hey \(emailField.text!), " + shareText
            
            let activityViewController = UIActivityViewController(activityItems: [newShareText, shareURL!], applicationActivities: nil)
            
            activityViewController.excludedActivityTypes = [UIActivityTypePostToFacebook, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo]
            
            presentViewController(activityViewController, animated: true, completion: nil)
            
        } else {
            
            let activityViewController = UIActivityViewController(activityItems: [shareText, shareURL!], applicationActivities: nil)
            
            activityViewController.excludedActivityTypes = [UIActivityTypePostToFacebook, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo]
            
            presentViewController(activityViewController, animated: true, completion: nil)
            
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

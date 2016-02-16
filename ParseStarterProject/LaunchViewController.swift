//
//  LaunchViewController.swift
//  Chore Balance
//
//  Created by Yifan Zhang on 2/16/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class LaunchViewController: UIViewController {
    
    override func viewDidAppear(animated: Bool) {
        
        //Check if user is already loggedin after screen shows up. Not sure if it's helpful
        let user = User.currentUser()
        if user?.objectId != nil {
            
            self.performSegueWithIdentifier("letsDoIt", sender: self)
            
        }
        
    }

}

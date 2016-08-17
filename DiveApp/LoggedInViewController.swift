//
//  LoggedInViewController.swift
//  DiveApp
//
//  Created by James O'Connor on 8/15/16.
//  Copyright © 2016 James O'Connor. All rights reserved.
//

import UIKit
import CloudKit

class LoggedInViewController: UIViewController {
    
    @IBOutlet weak var userNameLabel :UILabel!
    
    let currentUser :String! = NSUserDefaults.standardUserDefaults().stringForKey("currentUserName")
    
    var container :CKContainer!
    var publicDB :CKDatabase!
    var privateDB :CKDatabase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.container = CKContainer.defaultContainer()
        self.publicDB = container.publicCloudDatabase
        self.privateDB = container.privateCloudDatabase
        
        userNameLabel.text = currentUser
        
    }
    
    @IBAction func logoutButtonPressed() {
        
        
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isUserLoggedIn")
        let loginStatus :Bool = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")
        print(loginStatus)
        self.performSegueWithIdentifier("logoutSegue", sender: nil)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

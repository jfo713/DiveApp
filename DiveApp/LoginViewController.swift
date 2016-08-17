//
//  LoginViewController.swift
//  DiveApp
//
//  Created by James O'Connor on 8/15/16.
//  Copyright © 2016 James O'Connor. All rights reserved.
//

import UIKit
import CloudKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField :UITextField!
    @IBOutlet weak var passwordTextField :UITextField!

    var container :CKContainer!
    var publicDB :CKDatabase!
    var privateDB :CKDatabase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.container = CKContainer.defaultContainer()
        self.publicDB = container.publicCloudDatabase
        self.privateDB = container.privateCloudDatabase
        
    }
    
    @IBAction func loginButtonPressed() {
        
        let userName = userNameTextField.text
        let password = passwordTextField.text
        
        if (userName!.isEmpty || password!.isEmpty) {
            
            displayAlertMessage("All fields are Required")
            return;
            
        }
        
        checkUserLogin()
        
    }
    
    func loginSegue() {
        
        let loginStatus = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")
        if (loginStatus == true) {
            
            self.performSegueWithIdentifier("loginSucceedSegue", sender: self)
            
        }
        
    }
    
    func checkUserLogin() {
                
        let enteredUserName = userNameTextField.text
        let enteredPassword = passwordTextField.text
        
        let predicate = NSPredicate(format: "userName = %@ AND password = %@", enteredUserName!, enteredPassword!)
        
        let query = CKQuery(recordType: "Divers", predicate: predicate)
        
              
        publicDB.performQuery(query, inZoneWithID: nil) { (records: [CKRecord]?, error: NSError?) in
            
            if (records!.count == 0) {
                
                self.displayAlertMessage("Diver Record Not Found")
                return;
                
            }
            
            else {
                
                for record in records! {
                    
                    let userName = record["userName"] as! String
                    
                    print(userName)
                    
                    NSUserDefaults.standardUserDefaults().setObject(userName, forKey: "currentUserName")
                    
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUserLoggedIn")
                    
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                
                    self.loginSegue()
                }
                
            }
            
        }
    
    }
    
    func displayAlertMessage (userMessage :String) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            
            myAlert.addAction(okAction)
            
            self.presentViewController(myAlert, animated: true, completion: nil)
        
        
    }
    
}

}

//
//  RegisterViewController.swift
//  DiveApp
//
//  Created by James O'Connor on 8/15/16.
//  Copyright © 2016 James O'Connor. All rights reserved.
//

import UIKit
import CloudKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var userNameTextField :UITextField!
    @IBOutlet weak var passwordTextField :UITextField!
    @IBOutlet weak var confirmPasswordTextField :UITextField!
    
    var container :CKContainer!
    var publicDB :CKDatabase!
    var privateDB :CKDatabase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.container = CKContainer.defaultContainer()
        self.publicDB = container.publicCloudDatabase
        self.privateDB = container.privateCloudDatabase
        
    }
    
    @IBAction func registerButtonPressed(sender: AnyObject) {
    
        let userName = userNameTextField.text
        let password = passwordTextField.text
        let confirmPassword = confirmPasswordTextField.text
        
        if (userName!.isEmpty || password!.isEmpty || confirmPassword!.isEmpty) {
            
            displayAlertMessage("All Fields Are Required")
            return;
            
        }
        
        if (password! != confirmPassword!) {
            
            displayAlertMessage("Passwords Do Not Match")
            return;
            
        }
        
        doesUserExist()
        
    }
    
    func doesUserExist()  {
        
       let desiredUserName = userNameTextField.text
       
        let predicate = NSPredicate(format: "userName == %@", desiredUserName!)
        
        let query = CKQuery(recordType: "Divers", predicate: predicate)
        
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            
            if (results!.count == 0) {
                
                self.addDiverRecord()
                
            }
            
            else if (results!.count > 0) {
                
               self.displayAlertMessage("Username Already Registered")
                
            }
            
        }
        
    }
    
    func addDiverRecord() {
        
        let userName = userNameTextField.text
        let password = passwordTextField.text
        
        let diverRecord = CKRecord(recordType: "Divers")
        diverRecord["userName"] = userName
        diverRecord["password"] = password
        
        self.publicDB.saveRecord(diverRecord) { (record :CKRecord?, error :NSError?) in
            
            print(record?.recordID)
            
            self.displayAlertMessage("Registration Successful - Thank You!")
            
        }
        
    }
    
    func displayAlertMessage(userMessage :String) {
        
        dispatch_async(dispatch_get_main_queue()) { 
            
            let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            
            myAlert.addAction(okAction)
            
            self.presentViewController(myAlert, animated: true, completion: nil)

        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


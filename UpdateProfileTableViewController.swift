//
//  UpdateProfileTableViewController.swift
//  DiveApp
//
//  Created by James O'Connor on 8/16/16.
//  Copyright © 2016 James O'Connor. All rights reserved.
//

import UIKit
import CloudKit

class UpdateProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var container :CKContainer!
    var publicDB :CKDatabase!
    var privateDB :CKDatabase!
    
    var photoAsset :CKAsset!
    
    
    let currentUser :String! = NSUserDefaults.standardUserDefaults().stringForKey("currentUserName")

    @IBOutlet weak var firstNameTextField :UITextField!
    @IBOutlet weak var miTextField :UITextField!
    @IBOutlet weak var lastNameTextField :UITextField!
    @IBOutlet weak var dobTextField :UITextField!
    @IBOutlet weak var emailTextField :UITextField!
    @IBOutlet weak var addressFirstTextField :UITextField!
    @IBOutlet weak var addressSecondTextField :UITextField!
    @IBOutlet weak var cityTextField :UITextField!
    @IBOutlet weak var stateTextField :UITextField!
    @IBOutlet weak var zipTextField :UITextField!
    @IBOutlet weak var contactNameTextField :UITextField!
    @IBOutlet weak var contactRelationshipTextField :UITextField!
    @IBOutlet weak var contactPhoneTextField :UITextField!
    
    @IBOutlet weak var profilePicture :UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.container = CKContainer.defaultContainer()
        self.publicDB = container.publicCloudDatabase
        self.privateDB = container.privateCloudDatabase
        
        populateRecord()

    }
    
    func displayAlertMessage (userMessage :String) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            
            myAlert.addAction(okAction)
            
            self.presentViewController(myAlert, animated: true, completion: nil)
            
            
        }
    }
    
    func populateRecord() {
        
        let predicate = NSPredicate(format: "userName == %@", currentUser)
        let query = CKQuery(recordType: "Divers", predicate: predicate)
        
        publicDB?.performQuery(query, inZoneWithID: nil) { (records: [CKRecord]?, error :NSError?) in
            
            if (error != nil) {
                
                self.displayAlertMessage("Error Loading Your Profile")
                
            }
            
            else if (records!.count > 0) {
                
                let currentRecord = records![0]
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.firstNameTextField.text = currentRecord.objectForKey("firstName") as? String
                    self.miTextField.text = currentRecord.objectForKey("middleInitial") as? String
                    self.lastNameTextField.text = currentRecord.objectForKey("lastName") as? String
                    self.emailTextField.text = currentRecord.objectForKey("email") as? String
                    self.addressFirstTextField.text = currentRecord.objectForKey("firstAddress") as? String
                    self.addressSecondTextField.text = currentRecord.objectForKey("secondAddress") as? String
                    self.cityTextField.text = currentRecord.objectForKey("city") as? String
                    self.stateTextField.text = currentRecord.objectForKey("state") as? String
                    self.zipTextField.text = currentRecord.objectForKey("zip") as? String
                    self.contactNameTextField.text = currentRecord.objectForKey("emergencyName") as? String
                    self.contactRelationshipTextField.text = currentRecord.objectForKey("emergencyRelationship") as? String
                    self.contactPhoneTextField.text = currentRecord.objectForKey("emergencyPHone") as? String
                    
                    let birthDate = currentRecord.objectForKey("birthDate") as? NSDate
                    if birthDate != nil {
                        
                        let formatter = NSDateFormatter()
                        formatter.dateFormat = "dd/MM/yyyy"
                        let stringDate :String = formatter.stringFromDate(birthDate!)
                        self.dobTextField.text = stringDate
                        
                    }
                    
                 let profilePhoto = currentRecord.objectForKey("profilePhoto") as? CKAsset
                    
                    var image :UIImage!
                    var photoURL = NSURL()
                    if profilePhoto != nil {
                    
                        image = UIImage(contentsOfFile: (profilePhoto?.fileURL.path!)!)
                        photoURL = self.saveImageToFile(image!)
                        self.photoAsset = CKAsset(fileURL: photoURL)
                        
                        
                    }
                    
                    else {
                    
                            image = UIImage(named: "cameraIcon")
                        
                        }
                    
                    self.profilePicture.image = image
                    
                })
                
            }
        
        }
        
    }
    
    @IBAction func updateRecord() {
        
        let predicate = NSPredicate(format: "userName == %@", currentUser)
        
        let query = CKQuery(recordType: "Divers", predicate: predicate)
        
        publicDB?.performQuery(query, inZoneWithID: nil) { (records: [CKRecord]?, error: NSError?) in
            
            if (error != nil) {
                
                self.displayAlertMessage("Cloud Access Error")
                
            }
            
            else if (records!.count > 0) {
                
                let birthDateString = self.dobTextField.text
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let birthDate = dateFormatter.dateFromString(birthDateString!)
                let currentRecord = records![0]
                
                
                
                currentRecord.setObject(self.firstNameTextField.text, forKey: "firstName")
                currentRecord.setObject(self.miTextField.text, forKey: "middleInitial")
                currentRecord.setObject(self.lastNameTextField.text, forKey: "lastName")
                currentRecord.setObject(birthDate, forKey: "birthDate")
                currentRecord.setObject(self.emailTextField.text, forKey: "email")
                currentRecord.setObject(self.addressFirstTextField.text, forKey: "firstAddress")
                currentRecord.setObject(self.addressSecondTextField.text, forKey: "secondAddress")
                currentRecord.setObject(self.cityTextField.text, forKey: "city")
                currentRecord.setObject(self.stateTextField.text, forKey: "state")
                currentRecord.setObject(self.zipTextField.text, forKey: "zip")
                currentRecord.setObject(self.contactNameTextField.text, forKey: "emergencyName")
                currentRecord.setObject(self.contactRelationshipTextField.text, forKey: "emergencyRelationship")
                currentRecord.setObject(self.contactPhoneTextField.text, forKey: "emergencyPhone")
                
                currentRecord.setObject(self.photoAsset, forKey:"profilePhoto")
                
                self.publicDB.saveRecord(currentRecord, completionHandler: ( {returnRecord, error in
                    
                    if (error != nil) {
                        
                        self.displayAlertMessage("Error Saving Record")
                    }
                    
                    else {
                    
                        self.displayAlertMessage("Record Updated Successfully")
                        
                    }
                    
                }))
                
            }
        
        }
        
    }
    
    @IBAction func openImageOptions() {
        
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.delegate = self
        let alertController = UIAlertController(title: "Choose Your Profile Picture", message: nil, preferredStyle: .ActionSheet)
        
        let chooseFromLibraryAction = UIAlertAction(title:"Pick from Library", style: .Default)
        { (alert :UIAlertAction) in
            
            imagePickerViewController.sourceType = .PhotoLibrary
            self.presentViewController(imagePickerViewController, animated:true, completion: nil)
            
        }
        
        let takePictureAction = UIAlertAction(title:"Use Camera", style: .Default)
        { (alert :UIAlertAction) in
            
            imagePickerViewController.sourceType = .Camera
            self.presentViewController(imagePickerViewController, animated: true, completion:nil)
            
        }
        
        let cancelAction = UIAlertAction(title:"Cancel", style: .Cancel)
        { (alert :UIAlertAction) in
            
        }
        
        alertController.addAction(chooseFromLibraryAction)
        alertController.addAction(takePictureAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated:true, completion: nil)
        
    }
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var photoURL = NSURL()
        
        let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        
        self.profilePicture.image = originalImage
        
        dispatch_async(dispatch_get_main_queue()) {
            
            photoURL = self.saveImageToFile(self.profilePicture.image!)
        
            self.photoAsset = CKAsset(fileURL: photoURL)
            
        }
        
        picker.dismissViewControllerAnimated(true, completion:nil)
        
    }
    
    func saveImageToFile(image :UIImage) -> NSURL {
        
        let directoryPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let documentDirectory :AnyObject = directoryPaths[0]
        
        let filePath = documentDirectory.stringByAppendingPathComponent("profileImage.png")
        
        UIImageJPEGRepresentation(image, 0.2)!.writeToFile(filePath, atomically: true)
        
        return NSURL.fileURLWithPath(filePath)
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    
}

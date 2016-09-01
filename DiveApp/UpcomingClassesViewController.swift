//
//  UpcomingClassesViewController.swift
//  DiveApp
//
//  Created by James O'Connor on 8/19/16.
//  Copyright © 2016 James O'Connor. All rights reserved.
//

import UIKit
import JTAppleCalendar
import CloudKit

class UpcomingClassesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SignInViewDelegate, RegisterViewDelegate {
    
    @IBOutlet weak var calendarView :JTAppleCalendarView!
    @IBOutlet weak var monthLabel :UILabel!
    @IBOutlet weak var signInView :SignInView!
    @IBOutlet weak var registerView :RegisterView!
    @IBOutlet weak var saveButtonView :UIButton!
    @IBOutlet weak var clearButtonView :UIButton!
    
    @IBOutlet weak var chooseYourClassroomView :UIView!
    @IBOutlet weak var chooseYourFirstCWView :UIView!
    @IBOutlet weak var chooseYourSecondCWView :UIView!
    @IBOutlet weak var chooseYourFirstOWView :UIView!
    @IBOutlet weak var chooseYourSecondOWView :UIView!
    @IBOutlet weak var monthLabelView :UIView!
    
    @IBOutlet weak var chooseYourClassroomLabel :UILabel!
    @IBOutlet weak var chooseYourFirstCWLabel :UILabel!
    @IBOutlet weak var chooseYourSecondCWLabel :UILabel!
    @IBOutlet weak var chooseYourFirstOWLabel :UILabel!
    @IBOutlet weak var chooseYourSecondOWLabel :UILabel!
    
    @IBOutlet weak var selectedAppointmentsTableView :UITableView!
    
    let cellReuseIdentifier = "CellView"
    
    var cwReferenceArray :[CKReference] = [CKReference]()
    var owReferenceArray :[CKReference] = [CKReference]()
    
    var myOpenWaterCourse = OpenWaterCourse()
    
    var container :CKContainer!
    var publicDB :CKDatabase!
    var privateDB :CKDatabase!
    
    let formatter = NSDateFormatter()
    
    let calendar :NSCalendar! = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    
    var selectedDate = NSDate()
    var selectedDateModule :String?
    var selectedDateStringArray = [NSDate]()
    
    var requestedAppointments = [AppointmentObject]()
    
    
    var krDates = [NSDate]()
    var cwDates = [NSDate]()
    var owDates = [NSDate]()
    var krDateStrings = [String]()
    var cwDateStrings = [String]()
    var owDateStrings = [String]()
    
    @IBInspectable var krColor :UIColor!
    @IBInspectable var cwColor :UIColor!
    @IBInspectable var owColor :UIColor!
    @IBInspectable var normalDayColor :UIColor!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.container = CKContainer.defaultContainer()
        self.publicDB = container.publicCloudDatabase
        self.privateDB = container.privateCloudDatabase
        
        let appointmentObject1 = AppointmentObject()
        appointmentObject1.title = "Pool Appointment"
        
        
        
        //let backgroundImage :UIImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:"backgroundImage"]]
        
        //self.requestedAppointments.append(appointmentObject1)
        
        //self.selectedAppointmentsTableView.reloadData()
        
        self.populateArrays()
        
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.registerCellViewXib(fileName: "cellView")
       
        self.signInView.delegate = self
        self.registerView.delegate = self
        
//        selectedAppointmentsTableView.delegate = self
//        selectedAppointmentsTableView.dataSource = self
        
        self.calendarView.cellInset = CGPoint(x: 1, y: 1)
        calendarView.scrollToDate(NSDate(), triggerScrollToDateDelegate: false, animateScroll: false) {
            
            let currentDate = self.calendarView.currentCalendarDateSegment()
        
            self.setupViewsOfCalendar(currentDate.dateRange.start, endDate: currentDate.dateRange.end)
        }
                
    }
    
//MARK: IBAction
    
    @IBAction func changeToRegisterView() {
        
        print("Register Button Pressed")
        
        animateViewOutLeft(signInView)
        self.view.addSubview(registerView)
        animateViewToCenter(registerView)
        
    }
    
    @IBAction func alreadyRegistered() {
        
        animateViewOutRight(registerView)
        animateViewToCenter(signInView)
        
    }
    
    
    @IBAction func saveButton() {
        
        let logInStatus :Bool = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")
        
        if logInStatus == false {
            
            self.view.addSubview(self.signInView)
           
           // bookAppointmentsUserDefaults(requestedAppointments)
            
            fadeView(calendarView)
            //fadeView(selectedAppointmentsTableView)
            fadeView(monthLabel)
            fadeView(saveButtonView)
            fadeView(clearButtonView)
            
            animateViewToCenter(signInView)
            
        }
            
        else if logInStatus == true {
            
            bookDatesCloudKit(requestedAppointments)
            
            self.displayAlertMessage("Enrollment Successful!")
            
        }
    }
    
    @IBAction func clearButton() {
        
        requestedAppointments.removeAll()
        //selectedAppointmentsTableView.reloadData()
        
        resetText()
        
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "cacheDateArray")
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isUserLoggedIn")
        
    }

//MARK: Background Func
    
    func populateArrays() {

        formatter.dateFormat = "dd/MM/yyyy"
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Classes", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { (records :[CKRecord]?, error :NSError?) in
            
            for record in records! {
                
                if record.objectForKey("Module") as? String == "kr" {
                    
                    let krDate :NSDate = (record.objectForKey("Date") as? NSDate)!
                    self.krDates.append(krDate)
                    
                    let krDateString = self.formatter.stringFromDate(krDate)
                    self.krDateStrings.append(krDateString)
                    
                }
                
                if record.objectForKey("Module") as? String == "cw" {
                    
                    let cwDate :NSDate = (record.objectForKey("Date") as? NSDate)!
                    self.cwDates.append(cwDate)
                    
                    let cwDateString = self.formatter.stringFromDate(cwDate)
                    self.cwDateStrings.append(cwDateString)
                    
                }
                
                if record.objectForKey("Module") as? String == "ow" {
                    
                    let owDate :NSDate = (record.objectForKey("Date") as? NSDate)!
                    self.owDates.append(owDate)
                    
                    let owDateString = self.formatter.stringFromDate(owDate)
                    self.owDateStrings.append(owDateString)
                    
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
            self.calendarView.reloadData()
                
            }
        }
    }
    
    func setupViewsOfCalendar(startDate: NSDate, endDate: NSDate) {
        
        let date = NSDate()
        let month = calendar.component(NSCalendarUnit.Month, fromDate: startDate)
        let monthName = NSDateFormatter().monthSymbols[(month-1) % 12]
        let year = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: date)
        monthLabel.text = "Open Water Classes: " + monthName + ", \(year)"
        
    }
    
    func displayAlertMessage (userMessage :String) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            myAlert.addAction(okAction)
            self.presentViewController(myAlert, animated: true, completion: nil)
            
        }
    }
    
    func resetText() {
        
        chooseYourClassroomLabel.text = "Choose Your Classroom Date to Start"
        chooseYourFirstCWLabel.text = "Schedule Your First Pool Class"
        chooseYourSecondCWLabel.text = "Schedule Your Second Pool Class"
        chooseYourFirstOWLabel.text = "Plan Your First Day of Lake Diving"
        chooseYourSecondOWLabel.text = "Plan Your Second Day of Lake Diving"
        
    }
    
//MARK: SaveBookingFunctions
    
    func bookDatesCloudKit(appointmentArray :[AppointmentObject]) {
        
        let userName :String = (NSUserDefaults.standardUserDefaults().valueForKey("currentUserName") as? String)!
        let diverPredicate = NSPredicate(format: "userName == %@", userName)
        let diverQuery = CKQuery(recordType: "Divers", predicate: diverPredicate)
        publicDB.performQuery(diverQuery, inZoneWithID: nil) { (records: [CKRecord]?, error: NSError?) in

            guard let diverRecord = records?.first else {
                fatalError("Username not found")
            }
            
            let action = CKReferenceAction(rawValue: 1)
            let diverReference = CKReference(record: diverRecord, action: action!)
            let studentRecord = CKRecord(recordType: "UserClasses")
            studentRecord.setObject(diverReference, forKey: "Student")

            for appointment in appointmentArray {
                    
                let classPredicate = NSPredicate(format: "Module = %@ AND DateString = %@", appointment.moduleType!, appointment.appointmentDateString!)
                let classQuery = CKQuery(recordType: "Classes", predicate: classPredicate)
                self.publicDB.performQuery(classQuery, inZoneWithID: nil) { (classRecords: [CKRecord]?, error: NSError?) in
                        
                var cwReference :CKReference!
                var owReference :CKReference!
                        
                let saveAppointments = CKModifyRecordsOperation(recordsToSave: classRecords, recordIDsToDelete: nil)
            
                        for classRecord in classRecords! {
                            
                            if (classRecord["Module"] as! String == "kr") {
                                let krReference = CKReference(record: classRecord, action: action!)
                                studentRecord.setObject(krReference, forKey: "krClass")
                                print("kr")
                            }
                            
                            if (classRecord["Module"] as! String == "cw") {
                                
                               cwReference = CKReference(record: classRecord, action: action!)
                                
                                self.cwReferenceArray.append(cwReference)
                                print("cwArray")
                                
                            }
                            
                            if (classRecord["Module"] as! String == "ow") {
                                owReference = CKReference(record: classRecord, action: action!)
                                
                                self.owReferenceArray.append(owReference)
                                
                                print("owArray")

                            }
                            
                            studentRecord.setObject(self.cwReferenceArray, forKey: "cwClasses")
                            studentRecord.setObject(self.owReferenceArray, forKey: "owClasses")
                            print(self.cwReferenceArray.count)
                            print(self.owReferenceArray.count)
                            //END OF FOR LOOP

                        }
                    
                        self.publicDB.saveRecord(studentRecord) { (record :CKRecord?, error :NSError?) in
                            
                            print("recordSavedAgain with \(self.cwReferenceArray.count) and \(self.owReferenceArray.count)")
                            //print(cwReferenceArray.count)
                            
                            saveAppointments
                            
                        }
                    
                        //END OF QUERY COMPLETION HANDLER
                    }
                
                    //END OF FOR APPOINTMENTS
                }
            }
        }

//MARK: SignInFunctions
    
    func signInViewDidSignIn(userName: String!, password: String!) {
        
        if (userName.isEmpty || password.isEmpty) {
            
            displayAlertMessage("All Fields Are Required")
            return;
            
        }
        
        checkLogIn(userName, passwordString: password)
        
    }
    
    func checkLogIn(userNameString :String, passwordString :String) {
        
        let predicate = NSPredicate(format: "userName = %@ AND password = %@", userNameString, passwordString)
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
                    
                    self.animateViewOutTop(self.signInView)
                    self.signInView.usernameTextField.text = ""
                    self.signInView.passwordTextField.text = ""
                    self.unfadeView(self.calendarView)
                    //self.unfadeView(self.selectedAppointmentsTableView)
                    self.unfadeView(self.saveButtonView)
                    self.unfadeView(self.clearButtonView)
                    self.unfadeView(self.monthLabel)
                    
                }
            }
        }
    }
    
//MARK: RegisterFunctions
    
    func registerViewDidRegister(username: String!, password: String!, confirmPassword: String!) {
        
        if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
            
            displayAlertMessage("All Fields Are Required")
            return;
            
        }
        
        if (password != confirmPassword) {
            
            displayAlertMessage("Passwords Do Not Match")
            return;
            
        }
        
        doesUserExist(username, desiredPassword: password) {(userExists :Bool) in
            
            if userExists == true {
                
                self.displayAlertMessage("Username Already Exists")
                return;
                
            }
            
            else if userExists == false {
                
                self.addDiverRecord(username, newDiverPassword: password)
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.registerView.hidden = true
                    self.animateViewToCenter(self.signInView)
                    self.unfadeView(self.calendarView)
                    //self.unfadeView(self.selectedAppointmentsTableView)
                    self.unfadeView(self.saveButtonView)
                    self.unfadeView(self.clearButtonView)
                    self.unfadeView(self.monthLabel)
                    
                }
                
            }
        }
    }
    
    func doesUserExist(desiredUserName :String, desiredPassword :String, completion: (userExists :Bool) -> Void) {
        
        var userExistStatus = Bool()
        let predicate = NSPredicate(format: "userName == %@", desiredUserName)
        let query = CKQuery(recordType: "Divers", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            
            if results!.count == 0 {
                
                userExistStatus = false
                
                completion(userExists: userExistStatus)

                //self.addDiverRecord(desiredUserName, newDiverPassword: desiredPassword)
                
            }
                
            else if results!.count > 0 {
                
                userExistStatus = true
                
                completion(userExists: userExistStatus)
                
                self.displayAlertMessage("Username Already Registered")
                
            }
        }
    }
    
    func addDiverRecord(newDiverUserName :String, newDiverPassword :String) {
        
        let diverRecord = CKRecord(recordType: "Divers")
        diverRecord["userName"] = newDiverUserName
        diverRecord["password"] = newDiverPassword
        self.publicDB.saveRecord(diverRecord) { (record :CKRecord?, error :NSError?) in
            
            print(record?.recordID)
            self.displayAlertMessage("Registration Successful - Thank You! Please Log In.")
            
        }
    }
    
//MARK: AnimationFunctions
    
    override func viewWillAppear(animated: Bool) {
        
        let backgroundImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        let image = UIImage(named: "backgroundImage")
        backgroundImage.image = image
        
        //self.view.addSubview(backgroundImage)
        //self.view.sendSubviewToBack(backgroundImage)
        
        self.signInView.center.y -= super.view.frame.width
        self.signInView.center.x = super.view.frame.width/2
        self.signInView.layer.cornerRadius = 4
        self.signInView.backgroundColor = UIColor.lightGrayColor()
        
        self.registerView.center.y = super.view.frame.height/2
        self.registerView.center.x += super.view.frame.width
        self.registerView.layer.cornerRadius = 4
        self.registerView.backgroundColor = UIColor.lightGrayColor()
        
        //self.calendarView.layer.cornerRadius = 2
        
        chooseYourClassroomView.backgroundColor = krColor
        chooseYourFirstCWView.backgroundColor = cwColor
        chooseYourSecondCWView.backgroundColor = cwColor
        chooseYourFirstOWView.backgroundColor = owColor
        chooseYourSecondOWView.backgroundColor = owColor
        
        chooseYourClassroomView.alpha = 0.8
        chooseYourFirstCWView.alpha = 0.8
        chooseYourSecondCWView.alpha = 0.8
        chooseYourFirstOWView.alpha = 0.8
        chooseYourSecondOWView.alpha = 0.8
        
        self.chooseYourClassroomView.layer.cornerRadius = 3
        self.chooseYourFirstCWView.layer.cornerRadius = 3
        self.chooseYourSecondCWView.layer.cornerRadius = 3
        self.chooseYourFirstOWView.layer.cornerRadius = 3
        self.chooseYourSecondOWView.layer.cornerRadius = 3
        
        makeShadow(self.calendarView, shadowSize: 3)
        
        makeShadow(self.chooseYourClassroomView, shadowSize: 1)
        makeShadow(self.chooseYourFirstCWView, shadowSize: 1)
        makeShadow(self.chooseYourSecondCWView, shadowSize: 1)
        makeShadow(self.chooseYourFirstOWView, shadowSize: 1)
        makeShadow(self.chooseYourSecondOWView, shadowSize: 1)
        makeShadow(self.monthLabelView, shadowSize: 1)
        
        
    }
    
    func makeShadow(view :UIView, shadowSize :CGFloat) {
        
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSizeZero
        view.layer.shadowRadius = shadowSize
        view.layer.shouldRasterize = true
        
        
    }
    
    func fadeView(view :UIView) {
        
        UIView.animateWithDuration(0.2, animations: {
            
            view.alpha = 0.4
            
        })
        
    }
    
    func unfadeView(view :UIView) {
        
        UIView.animateWithDuration(0.2, animations: {
            
            view.alpha = 1.0
            
        })
        
    }
    
    func animateViewToCenter(view :UIView) {
        
        UIView.animateWithDuration(1.0, animations: {
            
            view.center.x = super.view.frame.width/2
            view.center.y = super.view.frame.height/2
        })
        
    }
    
    func animateViewOutTop(view :UIView) {
        
        UIView.animateWithDuration(1.0, animations:{
            
            
            
            view.center.x = super.view.frame.width/2
            view.center.y -= super.view.frame.height
            
        })
        
    }

    
    func animateViewOutLeft(view :UIView) {
        
        UIView.animateWithDuration(1.0, animations:{
            
            view.center.x -= super.view.frame.height
            view.center.y = super.view.frame.height/2
            
        })
        
    }
    
    func animateViewOutRight(view :UIView) {
        
        UIView.animateWithDuration(1.0, animations: {
            
            view.center.x += super.view.frame.height
            view.center.y = super.view.frame.height/2
            
        })
        
    }
    
}

extension UpcomingClassesViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func configureCalendar(calendar: JTAppleCalendarView) -> (startDate :NSDate, endDate :NSDate, numberOfRows :Int, calendar :NSCalendar) {
        
        formatter.dateFormat = "dd/MM/yyyy"
        
        let date = NSDate()
        let aCalendar = NSCalendar.currentCalendar()
        
        let components = aCalendar.components([.Year, .Month], fromDate: date)
        let startOfMonth = aCalendar.dateFromComponents(components)!
    
        let components2 = NSDateComponents()
        components2.month = 6
        
        let firstDate = startOfMonth
        let secondDate = aCalendar.dateByAddingComponents(components2, toDate: startOfMonth, options: [])!
       
        let numberOfRows = 4
        
        return(startDate: firstDate, endDate: secondDate, numberOfRows: numberOfRows, calendar: aCalendar)
        
    }
    
    func calendar(calendar: JTAppleCalendarView, didScrollToDateSegmentStartingWithdate startDate: NSDate, endingWithDate endDate: NSDate) {
        setupViewsOfCalendar(startDate, endDate: endDate)
        print(startDate, endDate)
    }
    
    func calendar(calendar: JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date: NSDate, cellState: CellState) {
        
        (cell as? CellView)?.setupCellBeforeDisplay(cellState, date: date)
        
        formatter.dateFormat = "dd/MM/yyyy"
        let cellDateString = formatter.stringFromDate(cellState.date)
        
        if krDateStrings.contains(cellDateString) {
            
            cell.backgroundColor = krColor
            
            
        }
    
        else if cwDateStrings.contains(cellDateString) {
            
            cell.backgroundColor = cwColor
            
        }
        
        else if owDateStrings.contains(cellDateString) {
            
            cell.backgroundColor = owColor
            
            
        }
        
        else {
            
            cell.backgroundColor = normalDayColor
            
        }
        
    }
    
    func calendar(calendar: JTAppleCalendarView, didSelectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        (cell as? CellView)?.cellSelectionChanged(cellState)
        
        let appointment = AppointmentObject() 
        appointment.appointmentDate = date
        appointment.appointmentDisplayText = appointment.appointmentDate?.toDisplayText()
        
        formatter.dateFormat = "dd/MM/yyyy"
        appointment.appointmentDateString = formatter.stringFromDate(date)
        
        sortModuleType(appointment.appointmentDateString!)
        appointment.moduleType = self.selectedDateModule
        
        if (appointment.moduleType == "kr") {
            
            appointment.appointmentColorCode = self.krColor
            self.myOpenWaterCourse.krAppointment = appointment
            
            self.chooseYourClassroomView.alpha = 1
            
            self.chooseYourClassroomLabel.text = "Classroom: \(self.myOpenWaterCourse.krAppointment!.appointmentDisplayText!)"
            
        }
        
        else if (appointment.moduleType == "cw") {
            
            appointment.appointmentColorCode = self.cwColor
            if (self.myOpenWaterCourse.cwAppointment1 == nil) {
                
                self.myOpenWaterCourse.cwAppointment1 = appointment
                
                self.chooseYourFirstCWView.alpha = 1
                
                self.chooseYourFirstCWLabel.text = "Pool 1: \(self.myOpenWaterCourse.cwAppointment1!.appointmentDisplayText!)"
                
            }
            
            else {
                
                self.myOpenWaterCourse.cwAppointment2 = appointment
                
                self.chooseYourSecondCWView.alpha = 1
                
                self.chooseYourSecondCWLabel.text = "Pool 2: \(self.myOpenWaterCourse.cwAppointment2!.appointmentDisplayText!)"
                
            }
            
        }
        
        else if (appointment.moduleType == "ow") {
            
            appointment.appointmentColorCode = self.owColor
            
            if (self.myOpenWaterCourse.owAppointment1 == nil) {
                
                self.myOpenWaterCourse.owAppointment1 = appointment
                
                self.chooseYourFirstOWView.alpha = 1
                
                self.chooseYourFirstOWLabel.text = "Lake Day 1: \(self.myOpenWaterCourse.owAppointment1!.appointmentDisplayText!)"
                
            }
        
            else {
                
                self.myOpenWaterCourse.owAppointment2 = appointment
                
                self.chooseYourSecondOWView.alpha = 1
                
                self.chooseYourSecondOWLabel.text = "Lake Day 2: \(self.myOpenWaterCourse.owAppointment2!.appointmentDisplayText!)"
                
            }
            
        }
        
        else if (appointment.moduleType == "noClass") {
            
            self.displayAlertMessage("There is no class scheduled for this date")
            return;
            
        }
        
        requestedAppointments.append(appointment)
        
        print(myOpenWaterCourse)
        
        //self.selectedAppointmentsTableView.reloadData()
        
    }
    
    func sortModuleType(stringDate :String) {
        
        if krDateStrings.contains(stringDate) {
            
            self.selectedDateModule = "kr"
            
        }
        
        else if cwDateStrings.contains(stringDate) {
            
            self.selectedDateModule = "cw"
            
        }
        
        else if owDateStrings.contains(stringDate) {
            
            self.selectedDateModule = "ow"
            
        }
        
        else {
            
            self.selectedDateModule = "noClass"
            
        }
        
    }
    
    func calendar(calendar: JTAppleCalendarView, didDeselectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        (cell as? CellView)?.cellSelectionChanged(cellState)
        
    }
    
    func calendar(calendar: JTAppleCalendarView, isAboutToResetCell cell: JTAppleDayCellView) {
        (cell as? CellView)?.selectedView.hidden = true
    }
    
    func calendar(calendar: JTAppleCalendarView, sectionHeaderIdentifierForDate date: (startDate: NSDate, endDate: NSDate)) -> String? {
        let comp = self.calendar.component(.Month, fromDate: date.startDate)
        if comp % 2 > 0{
            return "WhiteSectionHeaderView"
        }
        return "PinkSectionHeaderView"
    }
    
    func calendar(calendar: JTAppleCalendarView, sectionHeaderSizeForDate date: (startDate: NSDate, endDate: NSDate)) -> CGSize {
        
        if self.calendar.component(.Month, fromDate: date.startDate) % 2 == 1 {
            return CGSize(width: 200, height: 50)
        } else {
            return CGSize(width: 200, height: 100) // Yes you can have different size headers
        }
    }
    
    func calendar(calendar: JTAppleCalendarView, isAboutToDisplaySectionHeader header: JTAppleHeaderView, date: (startDate: NSDate, endDate: NSDate), identifier: String) {
        
        header.layer.cornerRadius = 2
    }
    
}



extension UpcomingClassesViewController {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return requestedAppointments.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("moduleCell", forIndexPath: indexPath) as! ClassModuleCell
        
        let cellAppointment :AppointmentObject = requestedAppointments[indexPath.row]
        cell.dateLabel.text = cellAppointment.appointmentDateString
        cell.textLabel?.text = cellAppointment.title
        
        cell.colorCodeView.backgroundColor = cellAppointment.appointmentColorCode
        
        return cell
    }

}

func delayRunOnMainThread(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
    }




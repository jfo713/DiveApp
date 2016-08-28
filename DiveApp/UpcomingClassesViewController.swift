//
//  UpcomingClassesViewController.swift
//  DiveApp
//
//  Created by James O'Connor on 8/19/16.
//  Copyright © 2016 James O'Connor. All rights reserved.
//

import UIKit
import JTAppleCalendar
import CoreData
import CloudKit

protocol BookDateDelegate :class {
    
    func bookDatesCoreData(addDates: [NSDate])
    
}

class UpcomingClassesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, BookDateDelegate, SignInViewDelegate {
    
    @IBOutlet weak var calendarView :JTAppleCalendarView!
    @IBOutlet weak var monthLabel :UILabel!
    @IBOutlet weak var signInView :SignInView!
    @IBOutlet weak var registerView :RegisterView!
    @IBOutlet weak var saveButtonView :UIButton!
    @IBOutlet weak var clearButtonView :UIButton!
    
    @IBOutlet weak var selectedClassesTableView :UITableView!
    
    let cellReuseIdentifier = "CellView"
    
    var container :CKContainer!
    var publicDB :CKDatabase!
    var privateDB :CKDatabase!
    
    
    
    var managedObjectContext :NSManagedObjectContext!
    var fetchedResultsController :NSFetchedResultsController!
    var dateObject :DateObject!
    
    let formatter = NSDateFormatter()
    
    let calendar :NSCalendar! = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    
    var selectedDate = NSDate()
    var selectedDates = [NSDate]()
    
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
        
        self.populateArrays()
        
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.registerCellViewXib(fileName: "cellView")
       
        self.signInView.delegate = self
        
        selectedClassesTableView.delegate = self
        selectedClassesTableView.dataSource = self
        
        self.calendarView.cellInset = CGPoint(x: 1, y: 1)
        calendarView.scrollToDate(NSDate(), triggerScrollToDateDelegate: false, animateScroll: false) {
            
            let currentDate = self.calendarView.currentCalendarDateSegment()
        
            self.setupViewsOfCalendar(currentDate.dateRange.start, endDate: currentDate.dateRange.end)
        }
        
        let fetchRequest = NSFetchRequest(entityName: "ClassDate")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        self.fetchedResultsController.delegate = self
        
        try! self.fetchedResultsController.performFetch()
        
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
            //self.signInView.delegate = self
           
            fadeView(calendarView)
            fadeView(selectedClassesTableView)
            fadeView(monthLabel)
            fadeView(saveButtonView)
            fadeView(clearButtonView)
            
            animateViewToCenter(signInView)
            
        
            
        }
            
        else if logInStatus == true {
            
            bookDatesCoreData(selectedDates)
            
            guard let testDates = self.fetchedResultsController.fetchedObjects else {
                fatalError("Error Fetching Results")
            }
            
            print(testDates.count)
            
        }
    }
    
    @IBAction func clearButton() {
        
        let fetchRequest = NSFetchRequest(entityName: "ClassDate")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let dateObjects = try! self.managedObjectContext.executeFetchRequest(fetchRequest) as? [DateObject]
        
        for dt in dateObjects! {
            
            self.managedObjectContext.deleteObject(dt)
            try!  self.managedObjectContext.save()
            
        }
        
        selectedDates.removeAll()
        selectedClassesTableView.reloadData()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isUserLoggedIn")
        
    }

//MARK: Animation Func
    
    override func viewWillAppear(animated: Bool) {
        self.signInView.center.y -= super.view.frame.width
        self.signInView.center.x = super.view.frame.width/2
        self.signInView.layer.cornerRadius = 4
        self.signInView.backgroundColor = UIColor.lightGrayColor()
        
        self.registerView.center.y = super.view.frame.height/2
        self.registerView.center.x += super.view.frame.width
        self.registerView.layer.cornerRadius = 4
        self.registerView.backgroundColor = UIColor.lightGrayColor()
        
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
                    
                    self.signInView.hidden = true
                    self.unfadeView(self.calendarView)
                    self.unfadeView(self.selectedClassesTableView)
                    self.unfadeView(self.saveButtonView)
                    self.unfadeView(self.clearButtonView)
                    self.unfadeView(self.monthLabel)
                    
                }
            }
        }
    }
    
    func bookDatesCoreData(addDates :[NSDate]) {
        
                for date in addDates {
            
            guard let newDate = NSEntityDescription.insertNewObjectForEntityForName("ClassDate", inManagedObjectContext: self.managedObjectContext) as? DateObject else {fatalError("dateObject failed to insert")}

            newDate.date = date
        
        try! self.managedObjectContext.save()
        
        }
        
    }
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            
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
        
        selectedDate = date
        
        selectedDates.append(selectedDate)
        
        formatter.dateFormat = "dd/MM/yyyy"
        let stringDate = formatter.stringFromDate(selectedDate)
        print(stringDate)
        
       self.selectedClassesTableView.reloadData()
        
        print(selectedDates.count)
    
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
    }
    
    
}

extension UpcomingClassesViewController {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return selectedDates.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("moduleCell", forIndexPath: indexPath) as! ClassModuleCell
        
        let date = selectedDates[indexPath.row]
        formatter.dateFormat = "dd/MM/yyyy"
        let stringDate = formatter.stringFromDate(date)
        cell.dateLabel.text = stringDate
        
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




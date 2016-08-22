//
//  UpcomingClassesViewController.swift
//  DiveApp
//
//  Created by James O'Connor on 8/19/16.
//  Copyright © 2016 James O'Connor. All rights reserved.
//

import UIKit
import JTAppleCalendar

class UpcomingClassesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var calendarView :JTAppleCalendarView!
    @IBOutlet weak var monthLabel :UILabel!
    @IBOutlet weak var dateSelectedLabel :UILabel!
    
    @IBOutlet weak var selectedClassesTableView :UITableView!
    
    let formatter = NSDateFormatter()
    let calendar :NSCalendar! = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    
    var selectedDate = NSDate()
    
    var selectedDates = [NSDate]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.registerCellViewXib(fileName: "cellView")
        
        selectedClassesTableView.delegate = self
        selectedClassesTableView.dataSource = self
        
        
        self.calendarView.cellInset = CGPoint(x: 1, y: 1)
        calendarView.reloadData()
        
        calendarView.scrollToDate(NSDate(), triggerScrollToDateDelegate: false, animateScroll: false) {
            
            let currentDate = self.calendarView.currentCalendarDateSegment()
        
            self.setupViewsOfCalendar(currentDate.dateRange.start, endDate: currentDate.dateRange.end)
            }
        
                
        }

    func setupViewsOfCalendar(startDate: NSDate, endDate: NSDate) {
        let date = NSDate()
        
        let month = calendar.component(NSCalendarUnit.Month, fromDate: startDate)
        let monthName = NSDateFormatter().monthSymbols[(month-1) % 12]
        let year = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: date)
        monthLabel.text = monthName + " " + String(year)
        
        }
    
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            
        }
    
}



extension UpcomingClassesViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func configureCalendar(calendar: JTAppleCalendarView) -> (startDate :NSDate, endDate :NSDate, numberOfRows :Int, calendar :NSCalendar) {
        
        formatter.dateFormat = "yyyy MM dd"
        
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
    }
    
    
    func calendar(calendar: JTAppleCalendarView, didSelectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        (cell as? CellView)?.cellSelectionChanged(cellState)
        
        selectedDate = date
        
        selectedDates.append(selectedDate)
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let stringDate = formatter.stringFromDate(selectedDate)
        dateSelectedLabel.text = stringDate
        
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


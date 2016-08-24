//
//  CellView.swift
//  DiveApp
//
//  Created by James O'Connor on 8/18/16.
//  Copyright © 2016 James O'Connor. All rights reserved.
//

import UIKit
import JTAppleCalendar
import CloudKit


class CellView: JTAppleDayCellView {
    
    @IBOutlet weak var dayLabel :UILabel!
    @IBOutlet weak var selectedView :AnimationView!
    @IBInspectable var normalDayColor  :UIColor!
    
    var container :CKContainer!
    var publicDB :CKDatabase!
    var privateDB :CKDatabase!
    
    var krDates :[NSDate] = [NSDate]()
    var cwDates :[NSDate] = [NSDate]()
    var owDates :[NSDate] = [NSDate]()
    
    let krColor = UIColor.yellowColor()
    let cwColor = UIColor.greenColor()
    let owColor = UIColor.blueColor()
    
    let textSelectedColor = UIColor(hue: 0.425, saturation: 0.55, brightness: 0.34, alpha: 1.0)
    let textDeselectedColor = UIColor(hue: 0.4417, saturation: 0.15, brightness: 1, alpha: 1.0)
    let previousMonthTextColor = UIColor(hue: 0.3694, saturation: 0.38, brightness: 0.57, alpha: 1.0)
    lazy var todayDate : String = {
        [weak self] in
        let aString = self!.c.stringFromDate(NSDate())
        return aString
        }()
    lazy var c : NSDateFormatter = {
        let f = NSDateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        
        return f
    }()
    
    func setupCellBeforeDisplay(cellState: CellState, date: NSDate) {
        
        self.container = CKContainer.defaultContainer()
        self.publicDB = container.publicCloudDatabase
        self.privateDB = container.privateCloudDatabase
        
        populateClasses(cellState)
        
        
        dayLabel.text = cellState.text
        
        configureTextColor(cellState)
        
        delayRunOnMainThread(0.0) {
            self.configueViewIntoBubbleView(cellState)
        }
        
        configureVisibility(cellState)
        
    }
    
    
    func populateClasses(cellState: CellState) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Classes", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { (records :[CKRecord]?, error :NSError?) in
            
            for record in records! {
                
                if record.objectForKey("Module") as? String == "kr" {
                    
                    let krDate :NSDate = (record.objectForKey("Date") as? NSDate)!
                    self.krDates.append(krDate)
                    
                }
                
                if record.objectForKey("Module") as? String == "cw" {
                    
                    let cwDate :NSDate = (record.objectForKey("Date") as? NSDate)!
                    self.cwDates.append(cwDate)
                
                }
                
                if record.objectForKey("Module") as? String == "ow" {
                    
                    let owDate :NSDate = (record.objectForKey("Date") as? NSDate)!
                    self.owDates.append(owDate)
                    
                }
                
            }
        
            self.configureBackgroundColor(cellState)
            
        }
        
    }
    
    func configureBackgroundColor(cellState: CellState) {

        let cellDateString = c.stringFromDate(cellState.date)
        
        for date in krDates {
            
                let krDateString = c.stringFromDate(date)
            
            if krDateString == cellDateString {
                
                self.backgroundColor = krColor
                
                }
            
            }
        
        for date in cwDates {
            
            let cwDateString = c.stringFromDate(date)
            
            if cwDateString == cellDateString {
                
                self.backgroundColor = cwColor
                
            }
        }
        
        for date in owDates {
            
            let owDateString = c.stringFromDate(date)
            
            if owDateString == cellDateString {
                
                self.backgroundColor = owColor
            }
            
        }
        
    }


    func configureTextColor(cellState: CellState) {
        
        if cellState.dateBelongsTo == .ThisMonth {
            
            dayLabel.textColor = UIColor.whiteColor()
        }
        
        else if cellState.dateBelongsTo == .PreviousMonthWithinBoundary || cellState.dateBelongsTo == .FollowingMonthWithinBoundary {
            
            dayLabel.textColor = UIColor.grayColor()
        }
        
    }
    
    func configureVisibility(cellState: CellState) {
        
        if cellState.dateBelongsTo == .ThisMonth || cellState.dateBelongsTo == .PreviousMonthWithinBoundary || cellState.dateBelongsTo == .FollowingMonthWithinBoundary {
            
            self.hidden = false }
        
        else { self.hidden = false}
            
    }
    
    func cellSelectionChanged(cellState: CellState) {
        if cellState.isSelected == true {
            if selectedView.hidden == true {
                configueViewIntoBubbleView(cellState)
                selectedView.animateWithBounceEffect(withCompletionHandler: {
                })
            }
        } else {
            configueViewIntoBubbleView(cellState, animateDeselection: true)
        }
    }
    
    private func configueViewIntoBubbleView(cellState: CellState, animateDeselection: Bool = false) {
        if cellState.isSelected {
            self.selectedView.layer.cornerRadius =  self.selectedView.frame.width  / 2
            self.selectedView.hidden = false
            configureTextColor(cellState)
            
        } else {
            if animateDeselection {
                configureTextColor(cellState)
                if selectedView.hidden == false {
                    selectedView.animateWithFadeEffect(withCompletionHandler: { () -> Void in
                        self.selectedView.hidden = true
                        self.selectedView.alpha = 0.5
                    })
                }
            } else {
                selectedView.hidden = true
            }
        }
    }
}

extension UIColor {
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

class AnimationView: UIView {
    
    func animateWithFlipEffect(withCompletionHandler completionHandler:(()->Void)?) {
        AnimationClass.flipAnimation(self, completion: completionHandler)
    }
    func animateWithBounceEffect(withCompletionHandler completionHandler:(()->Void)?) {
        let viewAnimation = AnimationClass.BounceEffect()
        viewAnimation(self){ _ in
            completionHandler?()
        }
    }
    func animateWithFadeEffect(withCompletionHandler completionHandler:(()->Void)?) {
        let viewAnimation = AnimationClass.FadeOutEffect()
        viewAnimation(self) { _ in
            completionHandler?()
        }
    }
}
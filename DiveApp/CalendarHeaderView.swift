//
//  CalendarHeaderView.swift
//  DiveApp
//
//  Created by James O'Connor on 8/18/16.
//  Copyright © 2016 James O'Connor. All rights reserved.
//

import UIKit
import JTAppleCalendar


class CalendarHeaderView: UIView {

    lazy var monthLabel :UILabel = {
        
        let label = UILabel()
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(13)
        label.textColor = UIColor.whiteColor()
        
        self.addSubview(label)
        
        return label
        
    }()
    
    lazy var weekdaysLabelsContainerView :UIView = {
        
        let view = UIView()
        let formatter :NSDateFormatter = NSDateFormatter()
        
        for index in 1...7 {
            
            let day: NSString = formatter.weekdaySymbols[index % 7] as NSString
            let weekdayLabel = UILabel()
            weekdayLabel.font = UIFont.systemFontOfSize(14)
            weekdayLabel.text = day.substringToIndex(1).uppercaseString
            weekdayLabel.textColor = UIColor.whiteColor()
            weekdayLabel.textAlignment = NSTextAlignment.Center
            
            view.addSubview(weekdayLabel)
            
        }
        
        self.addSubview(view)
        
        return view
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        
    let h = self.bounds.size.height / 2.0
        
    var monthLabelFrame = self.bounds
        monthLabelFrame.size.height = h
        
        self.monthLabel.frame = monthLabelFrame
        
        let dayLabelWidth = self.bounds.size.width / 7.0
        let dayLabelHeight = h
        var dayLabelFrame = CGRect(x:0, y: monthLabelFrame.size.height, width: dayLabelWidth, height: dayLabelHeight)
        
        for dayLabel in self.weekdaysLabelsContainerView.subviews {
            
            dayLabel.frame = dayLabelFrame
            dayLabelFrame.origin.x += dayLabelFrame.size.width
            
        }
        
    }

}













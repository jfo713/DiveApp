//
//  NSDate+Extensions.swift
//  DiveApp
//
//  Created by James O'Connor on 9/1/16.
//  Copyright © 2016 James O'Connor. All rights reserved.
//

import Foundation

extension NSDate {
    
    func toDisplayText() -> String {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        let displayText = formatter.stringFromDate(self)
        
        return displayText
        
    }
    
    func toString(format :String) -> String {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        
        
        return "Hello World"
    }
    
}
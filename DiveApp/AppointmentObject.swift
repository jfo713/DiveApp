//
//  AppointmentObject.swift
//  DiveApp
//
//  Created by James O'Connor on 8/29/16.
//  Copyright © 2016 James O'Connor. All rights reserved.
//

import UIKit

class AppointmentObject: NSObject {
    
    var appointmentDate :NSDate?
    var title :String?
    var moduleType :String?
    var appointmentDateString :String?
    var appointmentColorCode :UIColor?
    var appointmentDisplayText :String?
    
    var formatter :NSDateFormatter!
    
    override init() {
        
        self.formatter = NSDateFormatter()
        
        
    }
        
        
        
    

    
}



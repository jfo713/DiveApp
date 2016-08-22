//
//  CellView.swift
//  DiveApp
//
//  Created by James O'Connor on 8/18/16.
//  Copyright © 2016 James O'Connor. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CellView: JTAppleDayCellView {

    @IBOutlet weak var dayLabel :UILabel!
    @IBOutlet weak var selectedView :AnimationView!
    @IBInspectable var normalDayColor  :UIColor!
    @IBInspectable var weekendDayColor :UIColor!
    
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
        
        dayLabel.text = cellState.text
        configureTextColor(cellState)
        
        delayRunOnMainThread(0.0) {
            self.configueViewIntoBubbleView(cellState)
        }
        
        configureVisibility(cellState)
        
    }
    
    func configureTextColor(cellState: CellState) {
        
        if cellState.dateBelongsTo == .ThisMonth {
            
            dayLabel.textColor = UIColor.whiteColor()
        }
        
        else {
            
            dayLabel.textColor = weekendDayColor
            
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
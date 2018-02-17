//
//  TodayViewController.swift
//  macStatusSidePanel
//
//  Created by Yaroslav Movchan on 16.02.2018.
//  Copyright © 2018 letit0or1. All rights reserved.
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding {
    
    @IBOutlet weak var label: NSTextField!
    override var nibName: NSNib.Name? {
        return NSNib.Name("TodayViewController")
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        var strValue = ""
        for fan in SMCUtil.instance.getFans(){
            strValue += "\(fan.currentSpeed) |"
        }
        label.stringValue = strValue.isEmpty ?"empty":strValue
        completionHandler(.newData)
    }
}

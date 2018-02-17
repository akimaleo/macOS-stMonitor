//
//  ViewController.swift
//  stMonitor
//
//  Created by Yaroslav Movchan on 16.07.17.
//  Copyright © 2017 letit0or1. All rights reserved.
//

import Cocoa
import SystemConfiguration
import IOKit.ps
import IOKit.pwr_mgt

class ViewController: NSObject {
    
    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.system().statusItem(withLength: 80)
    @IBOutlet weak var infoView: InfoView!
    
    @IBOutlet weak var tabView: NSTabView!
    
    var itemWidth = 0.0
    //onCreate
    override func awakeFromNib() {
        //ITEM WIDTH
        let mySelectedAttributedTitle = NSAttributedString(string: "22°\n2222 | 2222", attributes:
            [NSFontAttributeName : NSFont.systemFont(ofSize: 10)])
        
        let size = mySelectedAttributedTitle.size()
        itemWidth = Double(size.width+30)
        statusItem.length = CGFloat(itemWidth)
        print(itemWidth)
        
        //ICON
        let icon = NSImage(named: "Image")
        icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
        statusMenu.items[0].view = infoView
        
        //BACKGROUND TIMER
        DispatchQueue.global(qos: .background).async {
            while true {
                DispatchQueue.main.async {
                    self.update()
                }
                sleep(3)
            }
        }
    }
    
    //SET TITLE TO STATUS ITEM WITH STYLE
    func setItemTitle(_ title:String){
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.maximumLineHeight = 10
        paragraphStyle.alignment = NSTextAlignment.center
        
        //TODO: set padding to top of text
        
        let mySelectedAttributedTitle = NSAttributedString(string: title, attributes:
            [NSFontAttributeName : NSFont.systemFont(ofSize: 10),
             NSParagraphStyleAttributeName: paragraphStyle,
             NSBaselineOffsetAttributeName:-2,
             NSLigatureAttributeName:0])
        
        statusItem.attributedTitle = mySelectedAttributedTitle
        statusItem.length = CGFloat(itemWidth)
        
    }
    
    //onUpdate
    @objc private func update(){
        infoView.cpuLabel.stringValue = ""
        printTemperatureInformation(known: true)
        printFanInformation()
        batteryInfo()
    }
    
    //CPU temperature
    func printTemperatureInformation(known: Bool = true) {
        print("-- Temperature --")
        let sensors = SMCUtil.instance.getSensors()
        for sensor in sensors {
            if sensor.name == "CPU_0_PROXIMITY"{
                setItemTitle("\(sensor.temperature)°\n")
                infoView.cpuLabel.stringValue += "CPU: \(sensor.temperature)°"
            }
            if sensor.name == "GPU"{
                infoView.cpuLabel.stringValue += "\nGPU: \(sensor.temperature)"
            }
        }
    }
    
    //Fan information print
    func printFanInformation() {
        print("-- Fan --")
        let allFans: [FanData] = SMCUtil.instance.getFans()
        for fan in allFans {
            if fan.id == 0{
                infoView.cpuLabel.stringValue += "\nLeft fan: \(fan.currentSpeed)"
                setItemTitle(statusItem.title!+"\(fan.currentSpeed)")
            }
            else if fan.id == 1{
                infoView.cpuLabel.stringValue += "\nRight fan: \(fan.currentSpeed)"
                setItemTitle(statusItem.title!+" | \(fan.currentSpeed)")
            }
        }
    }
}

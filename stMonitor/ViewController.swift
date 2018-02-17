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
        
        let sensors: [TemperatureSensor]
        do {
            if known {
                sensors = try SMCKit.allKnownTemperatureSensors().sorted
                    { $0.name < $1.name }
            } else {
                sensors = try SMCKit.allUnknownTemperatureSensors()
            }
            
        } catch {
            print(error)
            return
        }
        
        
        let sensorWithLongestName = sensors.max { $0.name.characters.count <
            $1.name.characters.count }
        
        guard let longestSensorNameCount = sensorWithLongestName?.name.characters.count else {
            print("No temperature sensors found")
            return
        }
        
        
        for sensor in sensors {
            
            guard let temperature = try? SMCKit.temperature(sensor.code) else {
                print("NA")
                return
            }
            if sensor.name == "CPU_0_PROXIMITY"{
                setItemTitle("\(temperature)°\n")
                infoView.cpuLabel.stringValue += "CPU: \(temperature)°"
            }
            if sensor.name == "GPU"{
                infoView.cpuLabel.stringValue += "\nGPU: \(temperature)"
            }
        }
    }
    
    //Fan information print
    func printFanInformation() {
        print("-- Fan --")
        let allFans: [FanData] = SMCUtil.instance.getFans()
        if allFans.count == 0 {
            print("No fans found")
            return}
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
    
    //Battery capacity information
    func batteryInfo(){
        //get power sources array
        let powerSourcesInfo : AnyObject! = IOPSCopyPowerSourcesInfo().takeUnretainedValue()
        let batteryArray : NSArray = IOPSCopyPowerSourcesList(powerSourcesInfo).takeUnretainedValue()
        
        //get power management object
        let nullPort : UInt32 = UInt32(MACH_PORT_NULL)
        let powerManagement : io_connect_t = IOPMFindPowerManagement(nullPort)
        
        //get power management battery info array
        let batteryInfoPtr : UnsafeMutablePointer<Unmanaged<CFArray>?> = UnsafeMutablePointer.allocate(capacity: MemoryLayout<Unmanaged<CFArray>?>.size)
        let batteryResult:IOReturn = IOPMCopyBatteryInfo(nullPort, batteryInfoPtr)
        let batteryInfo:NSArray? = batteryInfoPtr.pointee?.takeUnretainedValue()
        
        //close service
        IOServiceClose(powerManagement)
        
        //output data
        var batteryIndex:Int = 0
        for nextSource in batteryArray
        {
            //            infoView.cpuLabel.stringValue += "\nRight fan: \(currentSpeed)"
            //            print("Battery "+String(batteryIndex)+" Status:")
            //            print(nextSource)
            let pmBatteryPtr:UnsafeRawPointer = CFArrayGetValueAtIndex(batteryInfo, batteryIndex)
            batteryIndex+=1
            let pmBattery:Dictionary = unsafeBitCast(pmBatteryPtr, to: CFDictionary.self) as Dictionary
            let cycles = pmBattery["Cycle Count" as NSString] as! Int
            let fullCapacity = pmBattery["Capacity" as NSString] as! Int
            let currentCapacity = pmBattery["Current" as NSString] as! Int
            print(pmBattery as! Any)
            infoView.cpuLabel.stringValue += "\nCycle count: \(cycles)\nCapacity: \(currentCapacity)/\(fullCapacity) "
            
        }
    }
}


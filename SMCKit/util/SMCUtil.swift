//
//  SMCUtil.swift
//  stMonitor
//
//  Created by Yaroslav Movchan on 16.02.2018.
//  Copyright © 2018 letit0or1. All rights reserved.
//

import Foundation

class SMCUtil{
    //singleton instance
    static let instance = SMCUtil()
    //is SMCKit opened
    public var initialized:Bool = false
    
    private init(){
        if open(){
            print("initialized")
        }else{
            print("initialization error")
        }
    }
    
    //open SMCKit instance
    public func open() -> Bool{
        do {
            try SMCKit.open()
            initialized = true
        } catch {
            NotificationCenter.default.post(name: .openError, object: nil)
            initialized = false
        }
        return initialized
    }
    
    //get fans data array
    public func getFans() -> [FanData]{
        var retFans:[FanData] = []
        do {
            let fans = try SMCKit.allFans()
            for fan in fans{
                let curSpeed = try SMCKit.fanCurrentSpeed(fan.id)
                retFans += [ FanData(id: fan.id,
                                     name: fan.name,
                                     minSpeed: fan.minSpeed,
                                     maxSpeed: fan.maxSpeed,
                                     currentSpeed: curSpeed)]
            }
        } catch {
            NotificationCenter.default.post(name: .openError, object: nil)
        }
        return retFans
    }
    
    //get sensors array
    public func getSensors(known: Bool = true) -> [SensorData]{
        var sensors: [SensorData] = []
        var originSensors:[TemperatureSensor] = []
        do {
            if known {
                originSensors = try SMCKit.allKnownTemperatureSensors()
            } else {
                originSensors = try SMCKit.allUnknownTemperatureSensors()
            }
            sensors =  try originSensors.map{
                SensorData(name: $0.name,
                           code: $0.code,
                           temperature: try SMCKit.temperature($0.code))
            }
        } catch {
            print(error)
        }
        return sensors
    }
    
    //Battery capacity information
//    func batteryInfo(){
//        //get power sources array
//        let powerSourcesInfo : AnyObject! = IOPSCopyPowerSourcesInfo().takeUnretainedValue()
//        let batteryArray : NSArray = IOPSCopyPowerSourcesList(powerSourcesInfo).takeUnretainedValue()
//        
//        //get power management object
//        let nullPort : UInt32 = UInt32(MACH_PORT_NULL)
//        let powerManagement : io_connect_t = IOPMFindPowerManagement(nullPort)
//        
//        //get power management battery info array
//        let batteryInfoPtr : UnsafeMutablePointer<Unmanaged<CFArray>?> = UnsafeMutablePointer.allocate(capacity: MemoryLayout<Unmanaged<CFArray>?>.size)
//        let batteryResult:IOReturn = IOPMCopyBatteryInfo(nullPort, batteryInfoPtr)
//        let batteryInfo:NSArray? = batteryInfoPtr.pointee?.takeUnretainedValue()
//        
//        //close service
//        IOServiceClose(powerManagement)
//        
//        //output data
//        var batteryIndex:Int = 0
//        for nextSource in batteryArray
//        {
//            //            infoView.cpuLabel.stringValue += "\nRight fan: \(currentSpeed)"
//            //            print("Battery "+String(batteryIndex)+" Status:")
//            //            print(nextSource)
//            let pmBatteryPtr:UnsafeRawPointer = CFArrayGetValueAtIndex(batteryInfo, batteryIndex)
//            batteryIndex+=1
//            let pmBattery:Dictionary = unsafeBitCast(pmBatteryPtr, to: CFDictionary.self) as Dictionary
//            let cycles = pmBattery["Cycle Count" as NSString] as! Int
//            let fullCapacity = pmBattery["Capacity" as NSString] as! Int
//            let currentCapacity = pmBattery["Current" as NSString] as! Int
//            print(pmBattery as! Any)
//            infoView.cpuLabel.stringValue += "\nCycle count: \(cycles)\nCapacity: \(currentCapacity)/\(fullCapacity) "
//            
//        }
//    }
}

//names for notification actions
extension Notification.Name{
    static let openError = Notification.Name("error on open SMC")
    static let onFanGetError = Notification.Name("error get fan data")
}

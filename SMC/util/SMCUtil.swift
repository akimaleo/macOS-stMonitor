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
    
    func printTemperatureInformation() {
        print("-- Temperature --")
        let sensors: [SensorData] = getSensors()
        
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
                
            }
            if sensor.name == "GPU"{
                
            }
        }
    }
}

//names for notification actions
extension Notification.Name{
    static let openError = Notification.Name("error on open SMC")
    static let onFanGetError = Notification.Name("error get fan data")
}

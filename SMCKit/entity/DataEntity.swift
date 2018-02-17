//
//  File.swift
//  stMonitor
//
//  Created by Yaroslav Movchan on 16.02.2018.
//  Copyright © 2018 letit0or1. All rights reserved.
//

import Foundation

class FanData {
    var id:Int
    var name:String
    var minSpeed:Int
    var maxSpeed:Int
    var currentSpeed:Int
    
    init(id:Int, name:String, minSpeed:Int, maxSpeed:Int, currentSpeed:Int ) {
        self.id = id
        self.name = name
        self.minSpeed = minSpeed
        self.maxSpeed = maxSpeed
        self.currentSpeed = currentSpeed
    }
}

class SensorData{
    var name: String
    var code: FourCharCode
    var temperature:Double
    
    init(name: String, code: FourCharCode, temperature:Double){
        self.name = name
        self.code = code
        self.temperature = temperature
    }
}

class BatteryData{
    var cyclesCount:Int
    var fullCapacity:Int
    var currentCapacity:Int
    
    init(cyclesCount:Int, fullCapacity:Int, currentCapacity:Int){
        self.cyclesCount = cyclesCount
        self.fullCapacity = fullCapacity
        self.currentCapacity = currentCapacity
    }
}

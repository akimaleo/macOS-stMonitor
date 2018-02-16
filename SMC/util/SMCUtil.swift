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
        open()
    }
    
    //open SMCKit instance
    private func open() -> Bool{
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
}

//names for notification actions
extension Notification.Name{
    static let openError = Notification.Name("error on open SMC")
    static let onFanGetError = Notification.Name("error get fan data")
}

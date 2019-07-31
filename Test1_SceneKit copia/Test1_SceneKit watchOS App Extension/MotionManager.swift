//
//  MotionManager.swift
//  Test WatchKit Extension
//
//  Created by Gennaro Giaquinto on 11/07/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import Foundation
import CoreMotion
import WatchKit


protocol MotionManagerDelegate: class {
    func updatedRead(sound: Bool)
}

class MotionManager {
   
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    
    var flag: Bool = false
    var flag1: Bool = false
    
    let startThreshold = 3.00
    let soundThreshold = 2.00
    let raisingThreshold = 2.00
    
    let sampleInterval = 1.0 / 100
    
    weak var delegate: MotionManagerDelegate?
    
    init() {
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
    }
    
    
    func startUpdates() {
        if !motionManager.isDeviceMotionAvailable {
            print("Device Motion is not available.")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = sampleInterval
        motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            if error != nil {
                print("Encountered error: \(error!)")
            }
            
            if let data = deviceMotion?.rotationRate {
                let x = data.x
                let z = data.z
                
                if self.flag1 && x < self.raisingThreshold && z > self.raisingThreshold {
                    self.flag1 = false
                }
                
                if !self.flag1 && !self.flag && x > self.startThreshold && z < -self.startThreshold {
                    self.flag = true
                    self.flag1 = true
                }
                
                if self.flag && deviceMotion != nil {
                    self.processDeviceMotion(x: x, z: z)
                }
            }
        }
    }
    
    func stopUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    
    func processDeviceMotion(x: Double, z: Double) {
        
        //give more weight to the rotation around the yaw than the pitch
        let sum = (-x + z*2)/3
        
        flag = false
        
        delegate!.updatedRead(sound: sum >= soundThreshold)
    }
    
}

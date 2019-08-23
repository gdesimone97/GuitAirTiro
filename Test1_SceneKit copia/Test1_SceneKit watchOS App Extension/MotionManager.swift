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

/**
 `MotionManagerDelegate` exists to inform delegates of motion changes.
 These contexts can be used to enable application specific behavior.
 */
protocol MotionManagerDelegate: class {
    func updatedRead(sound: Bool)
}

class MotionManager {
    // MARK: Properties
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    
//    var buffer = PlayingBuffer(size: 1)
    
    var flag: Bool = false
    var flag1: Bool = false
    
    
    // MARK: Application Specific Constants
    
    let startThreshold = 3.00
    let soundThreshold = 2.00
    let raisingThreshold = 2.00
    
    
    // The app is using 100hz data and the buffer is going to hold 1s worth of data.
    let sampleInterval = 1.0 / 100
    
    weak var delegate: MotionManagerDelegate?
    
    
    // MARK: Initialization
    
    init() {
        // Serial queue for sample handling and calculations.
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
    }
    
    // MARK: Motion Manager
    
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
                
                if !self.flag1 && !self.flag && (x > self.startThreshold && z < -self.startThreshold) {
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
    
    // MARK: Motion Processing
    
    func processDeviceMotion(x: Double, z: Double) {
        
        //give more weight to the rotation around the yaw than the pitch
        let sum = (-x + z*2)/3
        
        
//        buffer.addSample(sum)
        
//        if !buffer.isFull() {
//            return
//        }
        flag = false
        
//        let sumAvg = buffer.sum()/buffer.size
//        buffer.reset()
//        buffer_pitch.reset()
        
        delegate!.updatedRead(sound: sum >= soundThreshold)
    }
    
}

//
//  PointerManager.swift
//  Test1_SceneKit tvOS
//
//  Created by Gennaro Giaquinto on 23/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit
import SceneKit

class PointerManager {
    let MIN_BAR = 0.01
    let MAX_BAR = 1.9
    
    let MIN_PLANE: Float = -2.85
    let MAX_PLANE: Float = -1.15
    let steps_plane: Float = 20.0
    
    private var movement: Float { return abs(MIN_PLANE - MAX_PLANE)/steps_plane }
    
    var progressBar: SCNNode!
    var recordBar: SCNNode!
    var pointer: SCNNode!
    var green: SCNNode!
    var yellow: SCNNode!
    var red: SCNNode!
    
    var record: Int
    
    var toCall: (() -> Void)!
    
    init(progressBar: SCNNode, recordBar: SCNNode, record: Int, recordBox: SCNNode, pointer: SCNNode, green: SCNNode, yellow: SCNNode, red: SCNNode, function: @escaping (() -> Void)) {
        self.progressBar = progressBar
        self.recordBar = recordBar
        self.record = record
        if record == 0 {
            recordBar.removeFromParentNode()
            progressBar.removeFromParentNode()
            recordBox.removeFromParentNode()
            self.progressBar = nil
            self.recordBar = nil
        }
        self.pointer = pointer
        self.green = green
        self.yellow = yellow
        self.red = red
        
        toCall = function
    }
    
    func modify(Up: Bool, actualPoints: Int) {
        if progressBar != nil {
            modifyBar(actualPoints: actualPoints)
        }
        
        if pointer.position.z < MIN_PLANE && Up {
            return
        }
        
        DispatchQueue.main.async {
            self.pointer.runAction(SCNAction.move(by: SCNVector3(x: 0, y: 0, z: (Up ? -Float(self.movement) : Float(self.movement))), duration: 0.5))
            self.modifyPlanes()
        }
        
        if pointer.position.z > MAX_PLANE {
            toCall()
        }
    }
    
    private func modifyPlanes() {
        if pointer.position.z > -1.7 {
            green.geometry?.firstMaterial!.metalness.contents = 1.0
            yellow.geometry?.firstMaterial!.metalness.contents = 1.0
            red.geometry?.firstMaterial!.metalness.contents = 0.0
        }
        if pointer.position.z <= -1.7 && pointer.position.z > -2.3 {
            green.geometry?.firstMaterial!.metalness.contents = 1.0
            yellow.geometry?.firstMaterial!.metalness.contents = 0.0
            red.geometry?.firstMaterial!.metalness.contents = 1.0
        }
        if pointer.position.z <= -2.3 {
            green.geometry?.firstMaterial!.metalness.contents = 0.0
            yellow.geometry?.firstMaterial!.metalness.contents = 1.0
            red.geometry?.firstMaterial!.metalness.contents = 1.0
        }
    }
    
    private func modifyBar(actualPoints: Int) {
        let x = Double(actualPoints) * ( MAX_BAR - MIN_BAR ) / Double(record)
        progressBar!.scale = SCNVector3(0.06, MIN_BAR + x, 0.06)
    }
}

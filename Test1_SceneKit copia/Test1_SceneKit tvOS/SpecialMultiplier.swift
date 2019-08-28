//
//  SpecialMultiplier.swift
//  Test1_SceneKit tvOS
//
//  Created by Gennaro Giaquinto on 28/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import Foundation
import SceneKit

class SpecialMultiplier {
    private let MIN: Float = 0
    private let MAX: Float = 1
    
    private var levelNode: SCNNode!
    
    init(node: SCNNode) {
        levelNode = node
    }
    
    func empty() {
        levelNode.runAction(SCNAction.scale(to: 0, duration: 0.5))
    }
    
    func fill() {
        var actualScale = levelNode.scale.y
        if actualScale < MAX {
            let newScale = actualScale + (MAX - MIN) * 1/5
            
            DispatchQueue(label: "level").async {
                while actualScale <= newScale {
                    actualScale += 0.05
                    self.levelNode.scale.y = actualScale
                    usleep(20000)
                }
            }
        }
    }
    
}

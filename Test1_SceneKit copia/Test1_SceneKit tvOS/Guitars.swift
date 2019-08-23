//
//  Guitars.swift
//  Test1_SceneKit tvOS
//
//  Created by Gennaro Giaquinto on 29/07/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit
import SceneKit

struct GuitarType {
    var guitarNode: SCNNode
    var y: Float?
}

enum GuitarsEnum {
    case acoustic
    case electric
}

class Guitars {
    
    var actualGuitar: GuitarType?
    
    var acoustic: GuitarType?
    var electric: GuitarType?
    
    private let scene: SCNScene
    
    
    init(scene: SCNScene, actualNode: SCNNode?) {
        self.scene = scene
        
        initializeNodes()
        
        if let node = actualNode {
            actualGuitar = GuitarType(guitarNode: node, y: nil)
        }
    }
    
    private func initializeNodes() {
        // Find all the guitars in the scene and initialize them
        let node = scene.rootNode.childNode(withName: "Node", recursively: false)
        scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "electricGuitar" {
                self.electric = initGuitar(node: node, y: -0.7)
            }
            if node.name == "acousticGuitar" {
                self.acoustic = initGuitar(node: node, y: -0.5)
            }
        }
    }
    
    private func initGuitar(node: SCNNode, y: Float) -> GuitarType {
        let guitar = GuitarType(guitarNode: node, y: y)
        
//        guitar.guitarNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: guitar.guitarNode, options: nil))
        guitar.guitarNode.physicsBody?.isAffectedByGravity = false
        guitar.guitarNode.physicsBody?.restitution = 1
        guitar.guitarNode.position = SCNVector3(x: 15, y: guitar.y!, z: 0)
        guitar.guitarNode.runAction(SCNAction.repeatForever(SCNAction.rotate(by: CGFloat.pi, around: SCNVector3(0, 1, 0), duration: 3)))
        
        return guitar
    }
    
    func changeGuitar(newGuitar: GuitarsEnum) {
        DispatchQueue.main.async {
            if let guitar = self.actualGuitar {
                guitar.guitarNode.runAction(SCNAction.sequence( [SCNAction.move(by: SCNVector3(x: -15, y: 0, z: 0), duration: 0.7), SCNAction.move(to: SCNVector3(x: 15, y: self.actualGuitar!.y!, z: 0), duration: 0) ] ) )
            }
            
            self.assign(guitar: newGuitar)
            self.actualGuitar!.guitarNode.runAction(SCNAction.move(to: SCNVector3(x: 0, y: self.actualGuitar!.y!, z: 0), duration: 0.7))
        }
    }
    
    func removeActual() {
        DispatchQueue.main.async {
            if let guitar = self.actualGuitar {
                guitar.guitarNode.runAction(SCNAction.sequence( [SCNAction.move(by: SCNVector3(x: -15, y: 0, z: 0), duration: 0.7), SCNAction.move(to: SCNVector3(x: 15, y: self.actualGuitar!.y!, z: 0), duration: 0) ] ) )
            }
        }
    }
    
    private func assign(guitar: GuitarsEnum) {
        switch guitar {
        case .acoustic:
            actualGuitar = acoustic
        case .electric:
            actualGuitar = electric
        }
    }
    
    
}

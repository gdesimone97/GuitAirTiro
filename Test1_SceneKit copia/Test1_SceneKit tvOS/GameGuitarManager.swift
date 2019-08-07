//
//  GameGuitarManager.swift
//  Test1_SceneKit tvOS
//
//  Created by Gennaro Giaquinto on 30/07/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit
import SceneKit
import AudioKit

class GameGuitarManager {
    
    struct ColumnType {
        let color: UIColor
        let xPosition: Float
    }
    
    private let scene: SCNScene
    private var width: Float
    private var length: Float
    private var z: Float
    private var changePoints: (Int, Bool) -> Void // This func is needed when this class have to directly modify the points of GameViewController
    
    private let column1: ColumnType
    private let column2: ColumnType
    private let column3: ColumnType
    private let column4: ColumnType
    
    
    let bokehEffectRed = SCNParticleSystem(named: "Art.scnassets/Bokeh Effect/SceneKit Particle System.scnp", inDirectory: nil)
    let bokehEffectBlue = SCNParticleSystem(named: "Art.scnassets/Bokeh Effect/SceneKit Particle System.scnp", inDirectory: nil)
    let bokehEffectGreen = SCNParticleSystem(named: "Art.scnassets/Bokeh Effect/SceneKit Particle System.scnp", inDirectory: nil)
    let bokehEffectPurple = SCNParticleSystem(named: "Art.scnassets/Bokeh Effect/SceneKit Particle System.scnp", inDirectory: nil)
    let fireEffect = SCNParticleSystem(named: "Art.scnassets/Fire Effect/SceneKit Particle System.scnp", inDirectory: nil)
    
    
    init(scene: SCNScene, width: Float, length: Float, z: Float, function: @escaping (Int, Bool) -> Void) {
        self.scene = scene
        self.width = width
        self.length = length
        self.z = z
        
        column1 = ColumnType(color: UIColor.red, xPosition: Float(-width/4 - width/2))
        column2 = ColumnType(color: UIColor.blue, xPosition: Float(-width/4))
        column3 = ColumnType(color: UIColor.green, xPosition: Float(width/4))
        column4 = ColumnType(color: UIColor.purple, xPosition: Float(width/4 + width/2))
        
        changePoints = function
        
        
        bokehEffectRed!.particleColor = column1.color
        bokehEffectBlue!.particleColor = column2.color
        bokehEffectGreen!.particleColor = column3.color
        bokehEffectPurple!.particleColor = column4.color
        
        
        DispatchQueue(label: "NotesNotPressed", qos: .userInteractive).async {
            while true {
                let node = scene.rootNode.childNodes
                scene.rootNode.enumerateChildNodes { (node, _) in
                    if node.name == "note" {
                        // If a node exceeds the limit clickable, it's a -1 point
                        if node.position.z > 0 {
                            self.changePoints(-1, false)
                            node.removeFromParentNode()
                        }
                    }
                }
                usleep(100000)
            }
        }
    }

    // Parameter indicates the column of the guitar
    func showNode(column: Int) {
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 5)
        let boxNode = SCNNode(geometry: box)
        boxNode.name = "note"
        
        if let col = findColumn(column: column) {
            boxNode.position = SCNVector3(col.xPosition, 0, z)
            
            let boxMaterial = SCNMaterial()
            boxMaterial.diffuse.contents = col.color
            boxMaterial.specular.contents = col.color
            boxMaterial.emission.contents = col.color
            boxMaterial.shininess = 1.0
            boxNode.geometry?.firstMaterial = boxMaterial
        }
        
        boxNode.opacity = 0
        
        let appearMoving = SCNAction.group( [SCNAction.fadeIn(duration: 0.5), SCNAction.move(by: SCNVector3(x: 0, y: 0, z: length), duration: 3.5)] )
        let remove = SCNAction.removeFromParentNode()
        let sequence = SCNAction.sequence([appearMoving, remove])
        
        DispatchQueue.main.async {
            self.scene.rootNode.addChildNode(boxNode)
            boxNode.runAction(sequence)
        }
        
    }
    
    
    // This func checks if a tap is good or not
    func checkPoint(column: Int) -> Bool {
        var flag = false
        
        // Prendo tutti i nodi presenti nella scena, controllo se stanno nella colonna specificata e restituisco true se stanno sul pulsante o no
        // Il pulsante è un cerchio di raggio = 1, posizione z = -1
        let node = scene.rootNode.childNodes
        scene.rootNode.enumerateChildNodes { (node, _) in
            if let pos = findPos(column: column) {
                if node.name == "note" && node.position.x == pos {
                    if node.position.z > -2 && node.position.z < 0 {
                        flag = true
                        node.removeFromParentNode()
                        bokeh(column: column)
                    }
                }
            }
        }
        
        return flag
    }
    
    
    func bokeh(column: Int) {
        let particleNode = SCNNode()
        
        let effect: SCNParticleSystem!
        switch column {
        case 1:
            effect = bokehEffectRed
        case 2:
            effect = bokehEffectBlue
        case 3:
            effect = bokehEffectGreen
        case 4:
            effect = bokehEffectPurple
        default:
            return
        }
        
        particleNode.addParticleSystem(effect)
        particleNode.position = SCNVector3(findPos(column: column)!, 0.1, -1)
        self.scene.rootNode.addChildNode(particleNode)

        let wait = SCNAction.wait(duration: 1)
        let remove = SCNAction.removeFromParentNode()
        
        DispatchQueue.main.async {
            particleNode.runAction(SCNAction.sequence([wait, remove]))
        }
    }
    
    func fire() {
        let particleNode1 = SCNNode()
        let particleNode2 = SCNNode()
        
        particleNode1.addParticleSystem(fireEffect!)
        particleNode2.addParticleSystem(fireEffect!)
        particleNode1.position = SCNVector3(-3.5, 0, -3)
        particleNode1.eulerAngles = SCNVector3(0, 0, -0.2)
        particleNode2.position = SCNVector3(3.5, 0, -3)
        particleNode2.eulerAngles = SCNVector3(0, 0, 0.2)
        
        self.scene.rootNode.addChildNode(particleNode1)
        self.scene.rootNode.addChildNode(particleNode2)
        
        let wait = SCNAction.wait(duration: 5)
        let remove = SCNAction.removeFromParentNode()
        
        DispatchQueue.main.async {
            particleNode1.runAction(SCNAction.sequence([wait, remove]))
            particleNode2.runAction(SCNAction.sequence([wait, remove]))
        }
    }
    
    
    private func findColumn(column: Int) -> ColumnType? {
        switch column {
        case 1:
            return column1
        case 2:
            return column2
        case 3:
            return column3
        case 4:
            return column4
        default:
            return nil
        }
    }
    
    func findPos(column: Int) -> Float? {
        switch column {
        case 1:
            return -width/4 - width/2
        case 2:
            return -width/4
        case 3:
            return width/4
        case 4:
            return width/4 + width/2
        default:
            return nil
        }
    }
    
}

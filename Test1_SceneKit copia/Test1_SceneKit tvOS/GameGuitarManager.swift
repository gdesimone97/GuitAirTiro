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
    
    private let column1: ColumnType
    private let column2: ColumnType
    private let column3: ColumnType
    private let column4: ColumnType
    
    let particleSystem = SCNParticleSystem(named: "Art.scnassets/Bokeh Effect/SceneKit Particle System.scnp", inDirectory: nil)
    
    
    
    init(scene: SCNScene, width: Float, length: Float, z: Float) {
        self.scene = scene
        self.width = width
        self.length = length
        self.z = z
        
        column1 = ColumnType(color: UIColor.red, xPosition: Float(-width/4 - width/2))
        column2 = ColumnType(color: UIColor.blue, xPosition: Float(-width/4))
        column3 = ColumnType(color: UIColor.green, xPosition: Float(width/4))
        column4 = ColumnType(color: UIColor.purple, xPosition: Float(width/4 + width/2))
        
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
    
    
    func checkPoint(column: Int) -> Bool {
        var flag = false
        
        // Prendo tutti i nodi presenti nella scena, controllo se stanno nella colonna specificata e restituisco true se stanno sul pulsante o no
        // Il pulsante è un cerchio di raggio = 1, posizione z = -1
        let node = scene.rootNode.childNodes
        scene.rootNode.enumerateChildNodes { (node, _) in
            if let pos = findPos(column: column) {
                if node.name == "note" && node.position.x == pos {
                    if node.position.z > -1.6 && node.position.z < -0 {
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
        particleNode.addParticleSystem(particleSystem!)
        particleNode.position = SCNVector3(findPos(column: column)!, 0.1, -1)
        self.scene.rootNode.addChildNode(particleNode)

        let wait = SCNAction.wait(duration: 1)
        let remove = SCNAction.removeFromParentNode()
        
        DispatchQueue.main.async {
            particleNode.runAction(SCNAction.sequence([wait, remove]))
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

//
//  GameGuitarManager.swift
//  Test1_SceneKit tvOS
//
//  Created by Gennaro Giaquinto on 30/07/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit
import SceneKit

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
    
    init(scene: SCNScene, width: Float, length: Float, z: Float) {
        self.scene = scene
        self.width = width
        self.length = length
        self.z = z
        
        column1 = ColumnType(color: UIColor.red, xPosition: Float(-width/4 - width/2))
        column2 = ColumnType(color: UIColor.green, xPosition: Float(-width/4))
        column3 = ColumnType(color: UIColor.blue, xPosition: Float(width/4))
        column4 = ColumnType(color: UIColor.yellow, xPosition: Float(width/4 + width/2))
    }

    // Parameter indicates the column of the guitar
    func showNode(column: Int) {
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 1)
        let boxNode = SCNNode(geometry: box)
        
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = UIColor.red
        boxMaterial.specular.contents = UIColor.red
        boxMaterial.emission.contents = UIColor.red
        boxMaterial.shininess = 1.0
        boxNode.geometry?.firstMaterial = boxMaterial
        
        boxNode.position = SCNVector3(column1.xPosition, 0, z)
        
        let appear = SCNAction.fadeIn(duration: 0.5)
        let move = SCNAction.move(by: SCNVector3(x: 0, y: 0, z: 10), duration: 2)
        let remove = SCNAction.removeFromParentNode()
        let sequence = SCNAction.sequence([appear, move, remove])
        
        DispatchQueue.main.async {
            self.scene.rootNode.addChildNode(boxNode)
            boxNode.runAction(sequence)
        }
        
    }

}

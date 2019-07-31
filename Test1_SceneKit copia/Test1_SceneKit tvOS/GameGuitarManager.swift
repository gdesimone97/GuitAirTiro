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
    
    enum Column : Int {
        case 1 = ColumnType(UIColor.red, column1)
        case 2 = [color: UIColor.green, position: column2]
        case 3 = [color: UIColor.yellow, position: column3]
        case 4 = [color: UIColor.blue, position: column4]
    }
    
    struct ColumnType {
        var color: UIColor
        var position: Float
    }
    
    private let scene: SCNScene
    private var width: Float
    private var length: Float
    private var z: Float
    
    private var column1: Float { return -width/4 - width/2 }
    private var column2: Float { return -width/4 }
    private var column3: Float { return width/4 }
    private var column4: Float { return width/4 + width/2 }
    
    init(scene: SCNScene, width: Float, length: Float, z: Float) {
        self.scene = scene
        self.width = width
        self.length = length
        self.z = z
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
        
        boxNode.position = SCNVector3(column1, 0, z)
    }

}

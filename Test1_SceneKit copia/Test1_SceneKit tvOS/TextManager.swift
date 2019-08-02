//
//  TextManager.swift
//  Test1_SceneKit tvOS
//
//  Created by Gennaro Giaquinto on 30/07/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit
import SceneKit

class TextManager {
    let scene: SCNScene
    
    init(scene: SCNScene) {
        self.scene = scene
    }
    
    func addNotification(str: String, color: UIColor) {
        let text = SCNText(string: str, extrusionDepth: 0.2)
        text.font = UIFont.italicSystemFont(ofSize: 1)
        let textNode = SCNNode(geometry: text)
        
        
        let textMaterial = SCNMaterial()
        textMaterial.diffuse.contents = color
        textMaterial.specular.contents = color
        textMaterial.emission.contents = color
        textMaterial.shininess = 1.0
        textNode.geometry?.firstMaterial = textMaterial
        
        textNode.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.1)
        let xLenght = (textNode.boundingBox.max.x - textNode.boundingBox.min.x)
        let yLenght = (textNode.boundingBox.max.y - textNode.boundingBox.min.y)
        textNode.position = SCNVector3(x: -xLenght/4, y: 1 + yLenght/2, z: 1)
        
        DispatchQueue.main.async {
            self.scene.rootNode.addChildNode(textNode)
            let wait = SCNAction.wait(duration: 2)
            let disappear = SCNAction.fadeOut(duration: 1)
            let remove = SCNAction.removeFromParentNode()
            textNode.runAction(SCNAction.sequence([wait, disappear, remove]))
        }
    }
    
    func addGameNotification(str: String, color: UIColor) {
        let text = SCNText(string: str, extrusionDepth: 0.2)
        text.font = UIFont.italicSystemFont(ofSize: 1)
        let textNode = SCNNode(geometry: text)
        
        
        let textMaterial = SCNMaterial()
        textMaterial.diffuse.contents = color
        textMaterial.specular.contents = color
        textMaterial.emission.contents = color
        textMaterial.shininess = 1.0
        textNode.geometry?.firstMaterial = textMaterial
        
        textNode.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.1)
        let xLenght = (textNode.boundingBox.max.x - textNode.boundingBox.min.x)
        let yLenght = (textNode.boundingBox.max.y - textNode.boundingBox.min.y)
        textNode.position = SCNVector3(x: -xLenght/4, y: 2 + yLenght/2, z: -1)
        
        DispatchQueue.main.async {
            self.scene.rootNode.addChildNode(textNode)
            let wait = SCNAction.wait(duration: 2)
            let disappear = SCNAction.fadeOut(duration: 0.5)
            let remove = SCNAction.removeFromParentNode()
            textNode.runAction(SCNAction.sequence([wait, disappear, remove]))
        }
    }
    
    
    func addCenteredText(str: String) {
        let text = SCNText(string: str, extrusionDepth: 0.2)
        text.font = UIFont.italicSystemFont(ofSize: 1)
        let textNode = SCNNode(geometry: text)
        let xLenght = (textNode.boundingBox.max.x - textNode.boundingBox.min.x)
        let yLenght = (textNode.boundingBox.max.y - textNode.boundingBox.min.y)
        // Positioned slightly to the left, and above the capsule (which is 10 units high)
        textNode.position = SCNVector3(x: -xLenght/2, y: 10, z: 1)
        self.scene.rootNode.addChildNode(textNode)
        let appear = SCNAction.move(to: SCNVector3(x: -xLenght/2, y: 3 + yLenght/2, z: 1), duration: 1)
        let wait = SCNAction.wait(duration: 3)
        let run = SCNAction.move(to: SCNVector3(x: -xLenght/2, y: -4, z: 1), duration: 1)
        let remove = SCNAction.removeFromParentNode()
        textNode.runAction(SCNAction.sequence([appear, wait, run, remove]))
    }
    
    
    // Position relative to the center of the screen
    // x -> MIN: -5.5, MAX: 5.5
    // y -> MIN: 0, MAX:
    func addTextAtPosition(str: String, x: Float, y: Float) -> SCNNode {
        let text = SCNText(string: str, extrusionDepth: 0.2)
        text.font = UIFont.systemFont(ofSize: 1)
        let textNode = SCNNode(geometry: text)
        
        textNode.scale = SCNVector3(x: 0.2, y: 0.2, z: 0.2)
        self.scene.rootNode.addChildNode(textNode)
        textNode.position = SCNVector3(x: x, y: y, z: 1)
        
        return textNode
    }
    
    
    // For the devices in the plane
    func addTextAtPosition(str1: String, str2: String, x: Float, y: Float, z: Float) {
        let text = SCNText(string: str1, extrusionDepth: 0.2)
        text.font = UIFont.italicSystemFont(ofSize: 1)
        let textNode = SCNNode(geometry: text)
        textNode.name = "Text:\(str2)"
        
        let textMaterial = SCNMaterial()
        textMaterial.diffuse.contents = UIColor.black
        textMaterial.specular.contents = UIColor.black
        textMaterial.emission.contents = UIColor.black
        textMaterial.shininess = 1.0
        textNode.geometry?.firstMaterial = textMaterial
        
        textNode.position = SCNVector3(x: x, y: y, z: z)
        textNode.scale = SCNVector3(x: 0, y: 0, z: 0)
        self.scene.rootNode.addChildNode(textNode)
        let wait = SCNAction.wait(duration: 0.3)
        let scale = SCNAction.scale(to: 0.3, duration: 0.01)
        textNode.runAction(SCNAction.sequence([wait, scale]))
    }
    
    
}

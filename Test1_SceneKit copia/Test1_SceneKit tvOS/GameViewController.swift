//
//  GameViewController.swift
//  Test1_SceneKit tvOS
//
//  Created by Gennaro Giaquinto on 24/07/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit
import SceneKit
import MultipeerConnectivity


class GameViewController: UIViewController {
    
    var gameView: SCNView {
        return self.view as! SCNView
    }
    
    var gameController: GameController!
    
    var box: SCNNode!
    var keyNode: SCNNode!
    var plane: SCNNode!
    var camera: SCNNode!
    var spot: SCNNode!
    
    var dictionary = DeviceDictionary()
    var session = SessionManager.share
    let semaphore = DispatchSemaphore(value: 1)
    let listPeerQueue = DispatchQueue(label: "listPeerQueue", qos: .userInteractive)
    
    // Connection Properties
    var planeNode: SCNNode!
    var flagPanelConnection = false
    var row = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session.delegate = self
        
        self.gameController = GameController(sceneRenderer: gameView)
        
        // Allow the user to manipulate the camera
        self.gameView.allowsCameraControl = false
            
        // Show statistics such as fps and timing information
//        self.gameView.showsStatistics = true
        
        // Configure the view
        self.gameView.backgroundColor = UIColor.black
        
        
        // Add a node in a scene
        let scene = SCNScene(named: "Art.scnassets/MainScene.scn")!
        gameView.scene = scene
        
        let waitAction = SCNAction.wait(duration: 5)
        let initAction = SCNAction.run{ _ in
            self.addContent()
        }
        let initAction2 = SCNAction.run{ _ in
            self.addElements()
        }
        
        gameView.scene?.rootNode.runAction(SCNAction.sequence([initAction, waitAction, initAction2]))
        
        self.addGestures()
        
        listPeerQueue.async {
            while true {
                if self.flagPanelConnection {
                    self.updatePeerList()
                }
                print("Ciao")
                self.semaphore.wait()
            }
        }
    }
    
    @objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        if !flagPanelConnection {
            showPlane()
            flagPanelConnection = !flagPanelConnection
        }
        else {
            // Forse non basta uno switch perchè non so il numero esatto di peer
            for index in dictionary.dictionary.keys {
                if Int(index)! == row {
                    print("Selezionato \(dictionary.dictionary[index])")
                }
            }
            hidePlane()
            showKey(pos: 0)
            row = 0
            flagPanelConnection = !flagPanelConnection
        }
        
    }
    
    @objc func handleSwipe(swipe: UISwipeGestureRecognizer) {
        if flagPanelConnection {
            switch swipe.direction.rawValue {
            // UpGesture
            case 4:
                if row > 1 {
                    row -= 1
                    showKey(pos: row)
                }
            // DownGesture
            case 8:
                if row < dictionary.dim {
                    row += 1
                    showKey(pos: row)
                }
            default:
                break
            }
            
            if row > 0 && row < dictionary.dim + 1 {
                self.gameView.scene!.rootNode.enumerateChildNodes { (node, _) in
                    let names = node.name?.split(separator: ":")
                    if names?[0] == "Text" && String((names?[1])!) == String(row) {
                        node.scale = SCNVector3(x: 0.35, y: 0.35, z: 0.3)
                    }
                    else if names?[0] == "Text" {
                        node.scale = SCNVector3(x: 0.3, y: 0.3, z: 0.3)
                    }
                }
            }

        }
    }
    
    func addGestures() {
        // Add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        var gestureRecognizers = gameView.gestureRecognizers ?? []
        gestureRecognizers.insert(tapGesture, at: 0)
        self.gameView.gestureRecognizers = gestureRecognizers
        
        // Add a swipe gesture recognizer
        let downGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(swipe:)))
        let upGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(swipe:)))
        downGesture.direction = UISwipeGestureRecognizer.Direction.down
        upGesture.direction = UISwipeGestureRecognizer.Direction.up
        self.view.addGestureRecognizer(downGesture)
        self.view.addGestureRecognizer(upGesture)
    }
    
    func addElements() {
        // Add a camera
//        let camera = SCNCamera()
//        camera.fieldOfView = 60
//
//        let cameraNode = SCNNode()
//        cameraNode.camera = camera
//        cameraNode.position = SCNVector3(x: 0, y: 3, z: 9)
//        cameraNode.eulerAngles = SCNVector3(x: 4, y: 0, z: 0)
//        gameView.scene?.rootNode.addChildNode(cameraNode)
        
        // Add a Fog Emitter
//        addEmitter()
        
        // Add a text
        addCenteredText(str: "GuitAir")
        addTextAtPosition(str: "Points: ", x: 5, y: 3)
        
    }
    
    func addContent() {
        let node = self.gameView.scene!.rootNode.childNode(withName: "Node", recursively: false)
        self.gameView.scene!.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "electricGuitar" {
                box = node
                box.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: box, options: nil))
                box.physicsBody?.isAffectedByGravity = false
                box.physicsBody?.restitution = 1
//                let up = SCNAction.move(to: SCNVector3(0, 0, 0.3), duration: 4)
//                let down = SCNAction.move(to: SCNVector3(0, -0.7, 0.3), duration: 4)
//                box.runAction(SCNAction.repeatForever(SCNAction.sequence([up, down])))
                box.runAction(SCNAction.repeatForever(SCNAction.rotate(by: CGFloat.pi, around: SCNVector3(box.position.x, box.position.y+1, box.position.z), duration: 3)))
            }
            if node.name == "camera" {
                camera = node
            }
            if node.name == "spot" {
                spot = node
            }
        }
    }
    
    
    func addEmitter() {
        fog(x: 7, y: 0.2, z: -3, roll: 0)
        fog(x: -7, y: 0.2, z: -3, roll: 0)
        fog(x: -6.5, y: 0.2, z: 0, roll: -CGFloat.pi/6)
        fog(x: 6.5, y: 0.2, z: 0, roll: CGFloat.pi/6)
        fog(x: -4, y: 0.2, z: 4, roll: -CGFloat.pi/3)
        fog(x: 4, y: 0.2, z: 4, roll: CGFloat.pi/3)
        fog(x: 0, y: 0.2, z: 4, roll: 0)
    }
    
    func showPlane() {
        if planeNode == nil {
            planeNode = SCNNode(geometry: SCNPlane(width: 5, height: 5))
            planeNode.position = SCNVector3(x: 0, y: 10, z: 1)
            
            let planeMaterial = SCNMaterial()
            planeMaterial.diffuse.contents = UIImage(named: "Art.scnassets/paper.png")
            planeMaterial.specular.contents = UIColor.black
            planeMaterial.emission.contents = UIColor.black
            planeMaterial.shininess = 1.0
            planeNode.geometry?.firstMaterial = planeMaterial
            
            self.gameView.scene?.rootNode.addChildNode(planeNode)
            
            planeNode.runAction(SCNAction.wait(duration: 5))
        }
        
        spot.light?.intensity = 500
        
        let goDown = SCNAction.move(by: SCNVector3(x: 0, y: -6, z: 0), duration: 1)
        let textAppear = SCNAction.run{ _ in
            self.updatePeerList()
        }
        planeNode.runAction(SCNAction.sequence([goDown, textAppear]))
    }
    
    func hidePlane() {
        if planeNode != nil {
            planeNode.runAction(SCNAction.move(by: SCNVector3(x: 0, y: 6, z: 0), duration: 1))
            spot.light?.intensity = 2000
        }
        self.gameView.scene!.rootNode.enumerateChildNodes { (node, _) in
            let names = node.name?.split(separator: ":")
            if names?[0] == "Text" {
                node.removeFromParentNode()
            }
        }
    }
    
    func updatePeerList() {
        self.gameView.scene!.rootNode.enumerateChildNodes { (node, _) in
            let names = node.name?.split(separator: ":")
            if names?[0] == "Text" {
                node.removeFromParentNode()
                print("rimosso")
            }
        }
        
        for pair in dictionary.dictionary {
            let text = SCNText(string: pair.value.displayName, extrusionDepth: 0.2)
            text.font = UIFont.italicSystemFont(ofSize: 1)
            let textNode = SCNNode(geometry: text)
            textNode.name = "Text:\(pair.key))"
            
            let textMaterial = SCNMaterial()
            textMaterial.diffuse.contents = UIColor.black
            textMaterial.specular.contents = UIColor.black
            textMaterial.emission.contents = UIColor.black
            textMaterial.shininess = 1.0
            textNode.geometry?.firstMaterial = textMaterial
            
            textNode.position = SCNVector3(x: -2, y: Float(5.95 - Double(Int(pair.key)!)/2.2), z: 1)
            textNode.scale = SCNVector3(x: 0.3, y: 0.3, z: 0.3)
            self.gameView.scene?.rootNode.addChildNode(textNode)
        }
    }
    
    // Pass 0 to hide the key
    func showKey(pos: Int) {
        if keyNode == nil {
            if pos != 0 {
                keyNode = SCNNode(geometry: SCNPlane(width: 0.5, height: 0.5))
                
                let keyMaterial = SCNMaterial()
                keyMaterial.diffuse.contents = UIImage(named: "Art.scnassets/Chiave.png")
                keyNode.geometry?.firstMaterial = keyMaterial
                
                self.gameView.scene?.rootNode.addChildNode(keyNode)
                keyNode.position = SCNVector3(x: -2.2, y: Float(6.3 - Double(pos)/2.2), z: 1.3)
            }
        } else {
            if pos == 0 {
                keyNode.removeFromParentNode()
                keyNode = nil
            }
            else {
                keyNode.position = SCNVector3(x: -2.2, y: Float(6.3 - Double(pos)/2.2), z: 1.3)
            }
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
        self.gameView.scene?.rootNode.addChildNode(textNode)
        let appear = SCNAction.move(to: SCNVector3(x: -xLenght/2, y: 3 + yLenght/2, z: 1), duration: 1)
        let wait = SCNAction.wait(duration: 3)
        let run = SCNAction.move(to: SCNVector3(x: -xLenght/2, y: -4, z: 1), duration: 1)
        let remove = SCNAction.removeFromParentNode()
        textNode.runAction(SCNAction.sequence([appear, wait, run, remove]))
    }
    
    func addCenteredText(pos: Int, str: String) {
        let text = SCNText(string: str, extrusionDepth: 0.2)
        text.font = UIFont.italicSystemFont(ofSize: 1)
        let textNode = SCNNode(geometry: text)
        textNode.name = "Text:\(pos)"
        
        let textMaterial = SCNMaterial()
        textMaterial.diffuse.contents = UIColor.black
        textMaterial.specular.contents = UIColor.black
        textMaterial.emission.contents = UIColor.black
        textMaterial.shininess = 1.0
        textNode.geometry?.firstMaterial = textMaterial
        
        // Positioned slightly to the left, and above the capsule (which is 10 units high)
        textNode.position = SCNVector3(x: -2, y: 10, z: 1)
        textNode.runAction(SCNAction.move(by: SCNVector3(x: 0, y: Float(-(10 - (5.95 - Double(pos)/2.2))), z: 0), duration: 2))
        textNode.scale = SCNVector3(x: 0.3, y: 0.3, z: 0.3)
        self.gameView.scene?.rootNode.addChildNode(textNode)
    }
    
    // Posizioni rispetto il centro della tv. LarghezzaMin : 6, LarghezzaMax: 8
    func addTextAtPosition(str: String, x: Float, y: Float) {
        let text = SCNText(string: str, extrusionDepth: 0.2)
        text.font = UIFont.systemFont(ofSize: 1)
        let textNode = SCNNode(geometry: text)
        let xLenght = (textNode.boundingBox.max.x - textNode.boundingBox.min.x)
        // Positioned slightly to the left, and above the capsule (which is 10 units high)
        textNode.position = SCNVector3(x: x - xLenght/2, y: 10, z: -3)
        textNode.eulerAngles = SCNVector3(x: 0, y: -0.2, z: 0)
        self.gameView.scene?.rootNode.addChildNode(textNode)
        
        
        let waitAction = SCNAction.wait(duration: 5)
        let compareAction = SCNAction.move(to: SCNVector3(x: x - xLenght/2, y: 3 + y, z: -3), duration: 2)
        let right = SCNAction.rotate(by: 0.4, around: SCNVector3(x: 0, y: 1, z: 0), duration: 3)
        let left = SCNAction.rotate(by: -0.4, around: SCNVector3(x: 0, y: 1, z: 0), duration: 3)
        let repeatAction = SCNAction.repeatForever(SCNAction.sequence([right, left]))
        textNode.runAction(SCNAction.sequence([waitAction, compareAction, repeatAction]))
    }
    
    func fog(x: Float, y: Float, z: Float, roll: CGFloat) {
        let particleSystem = SCNParticleSystem(named: "Smoke Effect/SceneKit Particle System.scnp", inDirectory: nil)
        
        let particleNode = SCNNode()
        particleNode.addParticleSystem(particleSystem!)
        self.gameView.scene?.rootNode.addChildNode(particleNode)
        particleNode.position = SCNVector3(x, y, z)
        particleNode.eulerAngles = SCNVector3(CGFloat.pi/2, roll, 0)
    }
    
}

extension GameViewController: SessionManagerDelegate {
    func peerFound(_ manger: SessionManager, peer: MCPeerID) {
        dictionary.addSample(peer: peer)
        semaphore.signal()
    }
    
    func peerLost(_ manager: SessionManager, peer lost: MCPeerID) {
        dictionary.removeSample(peer: lost)
        semaphore.signal()
    }
}





//CODICE ADDIZIONALE PER LE GESTURE

//// Add a tap gesture recognizer
//let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//var gestureRecognizers = gameView.gestureRecognizers ?? []
//gestureRecognizers.insert(tapGesture, at: 0)
//self.gameView.gestureRecognizers = gestureRecognizers
//
//// Add a swipe gesture recognizer
//let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(swipe:)))
//let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(swipe:)))
//rightGesture.direction = UISwipeGestureRecognizer.Direction.right
//leftGesture.direction = UISwipeGestureRecognizer.Direction.left
//self.view.addGestureRecognizer(rightGesture)
//self.view.addGestureRecognizer(leftGesture)
//
//
//    @objc
//    func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
//        // Highlight the tapped nodes
//        let p = gestureRecognizer.location(in: gameView)
//        print(p)
//        gameController.highlightNodes(atPoint: p)
//    }
//
//    @objc
//    func handleSwipe(swipe: UISwipeGestureRecognizer) {
//        let d: CGFloat = sqrt(2) / 2 * 9
//        switch swipe.direction.rawValue {
//        case 1:
//            //Disegna un ottagono intorno la chitarra
//            let act0 = SCNAction.group( [SCNAction.moveBy(x: d, y: 0, z: -9+d, duration: 0.2), SCNAction.rotateBy(x: 0, y: 0.25*CGFloat.pi, z: 0, duration: 0.2)] )
//            let act1 = SCNAction.group( [SCNAction.moveBy(x: 9-d, y: 0, z: -d, duration: 0.2), SCNAction.rotateBy(x: 0, y: 0.25*CGFloat.pi, z: 0, duration: 0.2)] )
//            let act2 = SCNAction.group( [SCNAction.moveBy(x: -9+d, y: 0, z: -d, duration: 0.2), SCNAction.rotateBy(x: 0, y: 0.25*CGFloat.pi, z: 0, duration: 0.2)] )
//            let act3 = SCNAction.group( [SCNAction.moveBy(x: -d, y: 0, z: -9+d, duration: 0.2), SCNAction.rotateBy(x: 0, y: 0.25*CGFloat.pi, z: 0, duration: 0.2)] )
//            let act4 = SCNAction.group( [SCNAction.moveBy(x: -d, y: 0, z: 9-d, duration: 0.2), SCNAction.rotateBy(x: 0, y: 0.25*CGFloat.pi, z: 0, duration: 0.2)] )
//            let act5 = SCNAction.group( [SCNAction.moveBy(x: -9+d, y: 0, z: d, duration: 0.2), SCNAction.rotateBy(x: 0, y: 0.25*CGFloat.pi, z: 0, duration: 0.2)] )
//            let act6 = SCNAction.group( [SCNAction.moveBy(x: 9-d, y: 0, z: d, duration: 0.2), SCNAction.rotateBy(x: 0, y: 0.25*CGFloat.pi, z: 0, duration: 0.2)] )
//            let act7 = SCNAction.group( [SCNAction.moveBy(x: d, y: 0, z: 9-d, duration: 0.2), SCNAction.rotateBy(x: 0, y: 0.25*CGFloat.pi, z: 0, duration: 0.2)] )
//
//            camera.runAction(SCNAction.sequence([act0, act1, act2, act3, act4, act5, act6, act7]))
//
//        case 2:
//            let act0 = SCNAction.group( [SCNAction.moveBy(x: -9, y: 0, z: -9, duration: 0.4), SCNAction.rotateBy(x: 0, y: -0.5*CGFloat.pi, z: 0, duration: 0.4)] )
//            let act1 = SCNAction.group( [SCNAction.moveBy(x: 9, y: 0, z: -9, duration: 0.4), SCNAction.rotateBy(x: 0, y: -0.5*CGFloat.pi, z: 0, duration: 0.4)] )
//            let act2 = SCNAction.group( [SCNAction.moveBy(x: 9, y: 0, z: 9, duration: 0.4), SCNAction.rotateBy(x: 0, y: -0.5*CGFloat.pi, z: 0, duration: 0.4)] )
//            let act3 = SCNAction.group( [SCNAction.moveBy(x: -9, y: 0, z: 9, duration: 0.4), SCNAction.rotateBy(x: 0, y: -0.5*CGFloat.pi, z: 0, duration: 0.4)] )
//
//            camera.runAction(SCNAction.sequence([act0, act1, act2, act3]))
//        default:
//            break
//        }
//    }




// ADD A GEOMETRIC FIGURE
//        let capsule = SCNCapsule(capRadius: 10, height: 2)
//        let capsuleNode = SCNNode(geometry: capsule)
//        capsuleNode.position = SCNVector3(x: 0, y: 0, z: 0)
//        scene.rootNode.addChildNode(capsuleNode)

// ADD A CAMERA
//        let camera = SCNCamera()
//        camera.fieldOfView =

//        let cameraNode = SCNNode()
//        cameraNode.camera = camera
//        cameraNode.position = SCNVector3(x: 0, y: 0, z: 20)
//        scene.rootNode.addChildNode(cameraNode)

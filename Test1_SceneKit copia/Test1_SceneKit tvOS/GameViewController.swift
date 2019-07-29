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
    
    var electricGuitar: SCNNode!
    var acousticGuitar: SCNNode!
    var keyNode: SCNNode!
    var plane: SCNNode!
    var camera: SCNNode!
    var spot: SCNNode!
    var numGuitar: Int = 2 // 2 for electric guitar, 1 for acoustic guitar
    // Assegnamento da fare in base alle UsersDefaults e NON QUI
    
    var dictionary = DeviceDictionary()
    var session = SessionManager.share
    let semaphore = DispatchSemaphore(value: 1)
    let peerListQueue = DispatchQueue(label: "peerListQueue", qos: .userInteractive)
    var peerConnected: MCPeerID?
    var connected: Int = 0 // -> 0: Disconnected, 1: Connecting, 2: Connected
    
    var deviceNode: SCNNode?
    
    
    
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
        
        peerListQueue.async {
            while true {
                self.peerListMain()
                self.semaphore.wait()
            }
        }
    }
    
    
    // Func needed to update interface immediatly
    func peerListMain() {
        DispatchQueue.main.async {
            if self.flagPanelConnection {
                self.updatePeerList()
                self.showKey(pos: 0)
                self.row = 0
            }
        }
    }
    
    @objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        if !flagPanelConnection {
            showPlane()
            flagPanelConnection = !flagPanelConnection
        }
        else {
            let rows = dictionary.dim + 1
            for index in 0...rows {
                if index == row {
                    if let peerID = dictionary.keyForValue(value: String(index)) {
                        print("Selezionato \(peerID)")
                        do {
                            try session.invitePeer(invite: peerID)
                            addNotification(str: "Connecting to the device!", color: UIColor.green)
                        } catch {
                            addNotification(str: "Unable to connect to that device!", color: UIColor.red)
                        }
                    }
                    hidePlane()
                    showKey(pos: 0)
                    row = 0
                    flagPanelConnection = !flagPanelConnection
                }
            }
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
                if row < dictionary.dim + 1 {
                    row += 1
                    showKey(pos: row)
                }
            default:
                break
            }
            
            if row > 0 && row < (dictionary.dim + 2) {
                self.gameView.scene!.rootNode.enumerateChildNodes { (node, _) in
                    let names = node.name?.split(separator: ":")
                    if names?[0] == "Text" && names![1] == String(row) {
                        node.scale = SCNVector3(x: 0.35, y: 0.35, z: 0.35)
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
        
        DispatchQueue.main.async {
            self.addCenteredText(str: "GuitAir")
            self.deviceNode = self.addTextAtPosition(str: "No device connected! Press the central button on the remote control to see the available devices", x: -5.5, y: 0.5)
        }
    }
    
    func addContent() {
        let node = self.gameView.scene!.rootNode.childNode(withName: "Node", recursively: false)
        self.gameView.scene!.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "electricGuitar" {
                electricGuitar = node
                electricGuitar.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: electricGuitar, options: nil))
                electricGuitar.physicsBody?.isAffectedByGravity = false
                electricGuitar.physicsBody?.restitution = 1
                electricGuitar.runAction(SCNAction.repeatForever(SCNAction.rotate(by: CGFloat.pi, around: SCNVector3(0, 1, 0), duration: 3)))
            }
            if node.name == "acousticGuitar" {
                acousticGuitar = node
                acousticGuitar.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: acousticGuitar, options: nil))
                acousticGuitar.physicsBody?.isAffectedByGravity = false
                acousticGuitar.physicsBody?.restitution = 1
                acousticGuitar.runAction(SCNAction.repeatForever(SCNAction.rotate(by: CGFloat.pi, around: SCNVector3(0, 1, 0), duration: 3)))
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
        }
        
        if let spot = spot  {
            spot.light!.intensity = 500
        }
        
        let goDown = SCNAction.move(by: SCNVector3(x: 0, y: -6, z: 0), duration: 0.4)
        let textAppear = SCNAction.run{ _ in
            self.updatePeerList()
        }
        planeNode.runAction(SCNAction.group([goDown, textAppear]))
    }
    
    func hidePlane() {
        if planeNode != nil {
            planeNode.runAction(SCNAction.move(by: SCNVector3(x: 0, y: 6, z: 0), duration: 0.4))
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
        // Cancel all nodes whose name starts with "Text" (are the ones in the peer list)
        self.gameView.scene!.rootNode.enumerateChildNodes { (node, _) in
            let names = node.name?.split(separator: ":")
            if names?[0] == "Text" {
                node.removeFromParentNode()
            }
        }
        
        // Re-write all nodes present in the dictionary
        for pair in dictionary.dictionary {
            let text = SCNText(string: pair.key.displayName, extrusionDepth: 0.2)
            text.font = UIFont.italicSystemFont(ofSize: 1)
            let textNode = SCNNode(geometry: text)
            textNode.name = "Text:\(pair.value)"
            
            let textMaterial = SCNMaterial()
            textMaterial.diffuse.contents = UIColor.black
            textMaterial.specular.contents = UIColor.black
            textMaterial.emission.contents = UIColor.black
            textMaterial.shininess = 1.0
            textNode.geometry?.firstMaterial = textMaterial
            
            textNode.position = SCNVector3(x: -2, y: Float(5.95 - Double(Int(pair.value)!)/2.2), z: 1)
            textNode.scale = SCNVector3(x: 0, y: 0, z: 0)
            self.gameView.scene?.rootNode.addChildNode(textNode)
            let wait = SCNAction.wait(duration: 0.3)
            let scale = SCNAction.scale(to: 0.3, duration: 0.01)
            textNode.runAction(SCNAction.sequence([wait, scale]))
        }
        
        // Then add the "CLOSE" label
        let text = SCNText(string: "CLOSE", extrusionDepth: 0.2)
        text.font = UIFont.italicSystemFont(ofSize: 1)
        let textNode = SCNNode(geometry: text)
        textNode.name = "Text:\(dictionary.dim + 1)"
        
        let textMaterial = SCNMaterial()
        textMaterial.diffuse.contents = UIColor.black
        textMaterial.specular.contents = UIColor.black
        textMaterial.emission.contents = UIColor.black
        textMaterial.shininess = 1.0
        textNode.geometry?.firstMaterial = textMaterial
        textNode.position = SCNVector3(x: -2, y: Float(5.95 - Double((dictionary.dim + 1))/2.2), z: 1)
        textNode.scale = SCNVector3(x: 0, y: 0, z: 0)
        self.gameView.scene?.rootNode.addChildNode(textNode)
        let wait = SCNAction.wait(duration: 0.3)
        let scale = SCNAction.scale(to: 0.3, duration: 0.01)
        textNode.runAction(SCNAction.sequence([wait, scale]))
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
    
    // Position relative to the center of the screen
    // x -> MIN: -5.5, MAX: 5.5
    // y -> MIN: 0, MAX:
    func addTextAtPosition(str: String, x: Float, y: Float) -> SCNNode {
        let text = SCNText(string: str, extrusionDepth: 0.2)
        text.font = UIFont.systemFont(ofSize: 1)
        let textNode = SCNNode(geometry: text)

//        textNode.eulerAngles = SCNVector3(x: 0, y: -0.2, z: 0)
        textNode.scale = SCNVector3(x: 0.2, y: 0.2, z: 0.2)
        let xLenght = (textNode.boundingBox.max.x - textNode.boundingBox.min.x)
        self.gameView.scene?.rootNode.addChildNode(textNode)
        textNode.position = SCNVector3(x: x, y: y, z: 1)
        
//        let compareAction = SCNAction.move(to: SCNVector3(x: x - xLenght/2, y: 3 + y, z: -3), duration: 2)
//        let right = SCNAction.rotate(by: 0.4, around: SCNVector3(x: 0, y: 1, z: 0), duration: 3)
//        let left = SCNAction.rotate(by: -0.4, around: SCNVector3(x: 0, y: 1, z: 0), duration: 3)
//        let repeatAction = SCNAction.repeatForever(SCNAction.sequence([right, left]))
//        textNode.runAction(SCNAction.sequence([compareAction, repeatAction]))
        
        return textNode
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
        
        self.gameView.scene?.rootNode.addChildNode(textNode)
        
        let wait = SCNAction.wait(duration: 2)
        let disappear = SCNAction.fadeOut(duration: 1)
        let remove = SCNAction.removeFromParentNode()
        textNode.runAction(SCNAction.sequence([wait, disappear, remove]))
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
    
    func nearPeerHasChangedState(_ manager: SessionManager, peer change: MCPeerID, connected: Int) {
        DispatchQueue.main.async {
            self.deviceNode!.removeFromParentNode()
            
            if self.connected == 0 && connected == 1 {
                self.connected = connected
                self.deviceNode = self.addTextAtPosition(str: "Connecting to \(change.displayName) ...", x: -5.5, y: 0.5)
            }
            else if self.connected == 1 && connected == 2 {
                self.connected = connected
                self.deviceNode = self.addTextAtPosition(str: "Device Connected: \(change.displayName)", x: -5.5, y: 0.5)
                self.peerConnected = change
            }
            else if self.peerConnected == change && self.connected == 2 && connected == 0 {
                self.connected = connected
                self.deviceNode = self.addTextAtPosition(str: "No device connected!", x: -5.5, y: 0.5)
            }
        }
    }
    
    func mexReceived(_ manager: SessionManager, didMessaggeReceived: UInt8) {
        DispatchQueue.main.async {
            switch Int(didMessaggeReceived) {
            case 1: // Guitar #1 has been selected (Acoustic)
                
                // See what was the selected guitar
                switch self.numGuitar {
                case 2: // Guitar #2 was selected (Electric)
                    let go = SCNAction.move(by: SCNVector3(x: -10, y: 0, z: 0), duration: 1)
                    let remove = SCNAction.run{_ in
                        self.electricGuitar.removeFromParentNode()
                    }
                    self.electricGuitar.runAction(SCNAction.sequence([go, remove]))
                    
                // If you add more guitars, you must add the other cases here
                default:
                    break
                }
                
                if self.numGuitar != 1 {
                    self.numGuitar = Int(didMessaggeReceived)
                    self.gameView.scene?.rootNode.addChildNode(self.acousticGuitar)
                    self.acousticGuitar.position = SCNVector3(x: 10, y: 0.7, z: 0)
                    self.acousticGuitar.runAction(SCNAction.move(by: SCNVector3(x: -10, y: 0, z: 0), duration: 0.7))
                }
                
            case 2: // Guitar #2 has been selected (Electric)
                
                // See what was the selected guitar
                switch self.numGuitar {
                case 1: // Guitar #1 was selected (Acoustic)
                    let go = SCNAction.move(by: SCNVector3(x: -10, y: 0, z: 0), duration: 1)
                    let remove = SCNAction.run{_ in
                        self.acousticGuitar.removeFromParentNode()
                    }
                    self.acousticGuitar.runAction(SCNAction.sequence([go, remove]))
                    
                // If you add more guitars, you must add the other cases here
                default:
                    break
                }
                
                if self.numGuitar != 2 {
                    self.numGuitar = Int(didMessaggeReceived)
                    self.gameView.scene?.rootNode.addChildNode(self.electricGuitar)
                    self.electricGuitar.position = SCNVector3(x: 10, y: 0.7, z: 0)
                    self.electricGuitar.runAction(SCNAction.move(by: SCNVector3(x: -10, y: 0, z: 0), duration: 0.7))
                }
                
            default:
                break
            }
        }
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

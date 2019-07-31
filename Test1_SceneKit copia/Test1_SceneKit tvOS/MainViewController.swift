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


class MainViewController: UIViewController {
    
    var gameView: SCNView {
        return self.view as! SCNView
    }
    
    var mainController: MainController!
    var textManager: TextManager!
    var guitarsManager: Guitars!
    
    var keyNode: SCNNode!
    var plane: SCNNode!
    var spot: SCNNode!
    
    
    var numGuitar: Int = 2 // 2 for electric guitar, 1 for acoustic guitar
    // Assegnamento da fare in base alle UsersDefaults e NON QUI
    
    
    var session = SessionManager.share
    let semaphore = DispatchSemaphore(value: 1)
    let peerListQueue = DispatchQueue(label: "peerListQueue", qos: .userInteractive)
    var peerConnected: MCPeerID?
    var connected: Int = 0 // -> 0: Disconnected, 1: Connecting, 2: Connected
    var deviceNode: SCNNode?
    
    
    
    // Connection Properties
    var dictionary = DeviceDictionary()
    var planeNode: SCNNode!
    var flagPanelConnection = false
    var row = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session.delegate = self
        
        self.mainController = MainController(sceneRenderer: gameView)
        
        // Allow the user to manipulate the camera
        self.gameView.allowsCameraControl = false
            
        // Show statistics such as fps and timing information
//        self.gameView.showsStatistics = true
        
        let waitAction = SCNAction.wait(duration: 5)
        let initAction = SCNAction.run{ _ in
            self.addContent()
        }
        let initAction2 = SCNAction.run{ _ in
            self.addElements()
        }
        
        gameView.scene?.rootNode.runAction(SCNAction.sequence([initAction, waitAction, initAction2]))
        
        self.textManager = TextManager(scene: gameView.scene!)
        
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
                            textManager.addNotification(str: "Request sent to the device", color: UIColor.green)
                        } catch {
                            textManager.addNotification(str: "Can't send the request!", color: UIColor.red)
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
        // Add a Fog Emitter
//        addEmitter()
        
        DispatchQueue.main.async {
            self.textManager.addCenteredText(str: "GuitAir")
            self.deviceNode = self.textManager.addTextAtPosition(str: "No device connected! Press the central button on the remote control to see the available devices", x: -5.5, y: 0.5)
        }
    }
    
    func addContent() {
        self.guitarsManager = Guitars(scene: self.gameView.scene!, actualNode: nil)
        
        let node = self.gameView.scene!.rootNode.childNode(withName: "Node", recursively: false)
        self.gameView.scene!.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "spot" {
                spot = node
            }
        }
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
            DispatchQueue.main.async {
                self.planeNode.runAction(SCNAction.move(by: SCNVector3(x: 0, y: 6, z: 0), duration: 0.4))
                self.spot.light?.intensity = 2000
            }
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
            textManager.addTextAtPosition(str1: pair.key.displayName, str2: pair.value, x: -2, y: Float(5.95 - Double(Int(pair.value)!)/2.2), z: 1)
        }
        
        // Then add the "CLOSE" label
        textManager.addTextAtPosition(str1: "EXIT", str2: String(dictionary.dim + 1), x: -2, y: Float(5.95 - Double((dictionary.dim + 1))/2.2), z: 1)
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
    
    
//    func addEmitter() {
//        fog(x: 7, y: 0.2, z: -3, roll: 0)
//        fog(x: -7, y: 0.2, z: -3, roll: 0)
//        fog(x: -6.5, y: 0.2, z: 0, roll: -CGFloat.pi/6)
//        fog(x: 6.5, y: 0.2, z: 0, roll: CGFloat.pi/6)
//        fog(x: -4, y: 0.2, z: 4, roll: -CGFloat.pi/3)
//        fog(x: 4, y: 0.2, z: 4, roll: CGFloat.pi/3)
//        fog(x: 0, y: 0.2, z: 4, roll: 0)
//    }
//
//    func fog(x: Float, y: Float, z: Float, roll: CGFloat) {
//        let particleSystem = SCNParticleSystem(named: "Smoke Effect/SceneKit Particle System.scnp", inDirectory: nil)
//
//        let particleNode = SCNNode()
//        particleNode.addParticleSystem(particleSystem!)
//        self.gameView.scene?.rootNode.addChildNode(particleNode)
//        particleNode.position = SCNVector3(x, y, z)
//        particleNode.eulerAngles = SCNVector3(CGFloat.pi/2, roll, 0)
//    }
    
    
}

extension MainViewController: SessionManagerDelegate {
    
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
                self.deviceNode = self.textManager.addTextAtPosition(str: "Connecting to \(change.displayName) ...", x: -5.5, y: 0.5)
            }
            else if self.connected == 1 && connected == 2 {
                self.deviceNode = self.textManager.addTextAtPosition(str: "Device Connected: \(change.displayName)", x: -5.5, y: 0.5)
                self.peerConnected = change
            }
            else if self.connected == 1 && connected == 0 {
                self.deviceNode = self.textManager.addTextAtPosition(str: "Device denied the request!", x: -5.5, y: 0.5)
            }
            else if self.peerConnected == change && self.connected == 2 && connected == 0 {
                self.deviceNode = self.textManager.addTextAtPosition(str: "No device connected!", x: -5.5, y: 0.5)
            }
            
            self.connected = connected
        }
    }
    
    func mexReceived(_ manager: SessionManager, didMessaggeReceived: SignalCode) {
        switch didMessaggeReceived {
        case .showAcousticGuitar:
            self.guitarsManager.changeGuitar(newGuitar: .acoustic)
        case .showElectricGuitar:
            self.guitarsManager.changeGuitar(newGuitar: .electric)
        case .openGame:
            self.performSegue(withIdentifier: "GameSegue", sender: nil)
            
            
            
        // Add more cases here
        default:
            break
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
//        mainController.highlightNodes(atPoint: p)
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

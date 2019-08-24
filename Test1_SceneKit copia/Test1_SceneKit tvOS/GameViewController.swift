//
//  GameViewController.swift
//  Test1_SceneKit tvOS
//
//  Created by Gennaro Giaquinto on 30/07/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit
import SceneKit
import MultipeerConnectivity
import AudioKit
import GameController

protocol ReactToMotionEvents {
    func motionUpdate(motion: GCMotion) -> Void
}


class GameViewController: UIViewController {
    
    var gameView: SCNView {
        return self.view as! SCNView
    }
    
    var motionDelegate: ReactToMotionEvents?
    
    var gameController: GameController!
    var gameGuitarManager: GameGuitarManager!
    var textManager: TextManager!
    var soundEffect: SoundEffect!
    var pointerManager: PointerManager!
    
    var session = SessionManager.share
    var dictionary: DeviceDictionary!
    
    let semaphoreStart = DispatchSemaphore(value: 0)
    let semaphorePlay = DispatchSemaphore(value: 0)
    
    // This closure is used for setting the Session Delegate when the this View is dismissed
    // It is setted by the View that opens this view
    var callbackClosure: ( () -> Void )?
    
    override func viewWillDisappear(_ animated: Bool) {
        sendSignalWhenClosing()
        soundEffect.stopGuitars()
        self.playing = false
        
        callbackClosure?()
    }
    
    var button1: SCNNode!
    var button2: SCNNode!
    var button3: SCNNode!
    var button4: SCNNode!
    var background: SCNNode!
    
    var button1Pressed: Bool = false
    var button2Pressed: Bool = false
    var button3Pressed: Bool = false
    var button4Pressed: Bool = false
    
    var goodNote: Bool = false
    var movedController: Bool = false
    
    
    var playing: Bool = false
    var points = 0
    var multiplier = 1
    var consecutivePoints: Int = 0
    
    var chords: [String]! // Those 2 vars are initialized by the mainViewController
    
    var boxStartNode: SCNNode?
    var pointText: SCNNode?
    var multiplierNode: SCNNode?
    var consecutivePointsNode: SCNNode?
    var pointsPlaneNode: SCNNode?
    var pointerNode: SCNNode?
    var greenBoxNode: SCNNode?
    var yellowBoxNode: SCNNode?
    var redBoxNode: SCNNode?
    var recordBarNode: SCNNode?
    var progressBarNode: SCNNode?
    var recordPlaneNode: SCNNode?
    var failedPlaneNode: SCNNode?
    var consecutivePlaneNode: SCNNode?
    
    
    var song: Songs = Songs.LaCanzoneDelSole // Da settare dal telefono
    var songRecord: Int = 140 // DA SETTARE DAL TELEFONOOOOO
    
    // This is the thread that shows nodes on the guitar
    let noteQueue = DispatchQueue(label: "noteQueue", qos: .userInteractive)
    let pointsQueue = DispatchQueue(label: "pointsQueue", qos: .userInteractive)
    let startQueue = DispatchQueue(label: "startQueue", qos: .userInteractive)
    
    var soundThreshold = 2.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameController = GameController(sceneRenderer: gameView)
        
        session.delegate = self
        
        gameGuitarManager = GameGuitarManager(scene: gameView.scene!, width: 2.5, length: 20, z: -17, function: changePoints(point:))
        textManager = TextManager(scene: gameView.scene!)
        soundEffect = SoundEffect(file1: chords[0], file2: chords[1], file3: chords[2], file4: chords[3])
        
        
        // Allow the tapGesture on the remote
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        var gestureRecognizers = gameView.gestureRecognizers ?? []
        gestureRecognizers.insert(tapGesture, at: 0)
        self.gameView.gestureRecognizers = gestureRecognizers
        
        addElements()
        replaceBackgroundImage()
        
        startQueue.async {
            sleep(1)
            self.points = 0
            self.boxStartNode?.runAction(SCNAction.fadeIn(duration: 0.5))
            self.semaphoreStart.wait()
            self.boxStartNode!.removeFromParentNode()
            self.soundEffect.countdown()
            self.textManager.addGameNotification(str: "3", color: UIColor.white, duration: 0.5, animation: true)
            sleep(1)
            self.textManager.addGameNotification(str: "2", color: UIColor.white, duration: 0.5, animation: true)
            sleep(1)
            self.textManager.addGameNotification(str: "1", color: UIColor.white, duration: 0.5, animation: true)
            sleep(1)
            self.textManager.addGameNotification(str: "GO!", color: UIColor.white, duration: 0.5, animation: true)
            self.pointsPlaneNode?.runAction(SCNAction.move(to: SCNVector3(x: -4, y: 0.5, z: -2), duration: 0.3))
            sleep(1)
            self.playing = true
            
            // Called 2 times to unlock all the 2 threads waiting
            self.semaphorePlay.signal()
            self.semaphorePlay.signal()
        }
        
        
        pointsQueue.async {
            self.semaphorePlay.wait()
            while self.playing {
                self.updatePoints()
                usleep(100000)
            }
        }
        
        noteQueue.async {
            // This thread shows the notes to play taking the song's string
            self.semaphorePlay.wait()
            for pair in self.song.notes.split(separator: ";") {
                let x = pair.split(separator: ":")
                for i in 0..<x.count-1 {
                    self.gameGuitarManager.showNode(column: Int(x[i])!)
                }
                
                usleep(UInt32(x[x.count-1])!)
            }
            
            sleep(3)
            
            if self.playing {
                // when the song stops
                self.motionDelegate = nil
                self.soundEffect.applauseSound()
                if self.points > 0 {
                    self.textManager.addGameNotification(str: "You did \(self.points) points!", color: UIColor.white, duration: 3, animation: false)
                }
                
                self.gameGuitarManager.fire()
                sleep(4)
                DispatchQueue.main.async {
                    self.dismiss(animated: false, completion: nil)
                }
            }
        }
        
        // Setto il motionDelegate del controller
        motionDelegate = self
        
        pointerManager = PointerManager(progressBar: progressBarNode!, recordBar: recordBarNode!, record: songRecord, recordBox: recordPlaneNode!, pointer: pointerNode!, green: greenBoxNode!, yellow: yellowBoxNode!, red: redBoxNode!, function: failed)
        
    }
    
    
    @objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        if playing {
            gameGuitarManager.fire()
        }
        
        if !playing {
            //Cerco tra i controller disponibili, il Remote
            let controllers = GCController.controllers()
            for controller in controllers {
                if controller.vendorName! == "Remote" {
                    // Setto l'handler, ovvero il blocco che verrà eseguito ogni volta che un valore qualsiasi del controller cambia
                    controller.motion?.valueChangedHandler = { (motion: GCMotion)->() in
                        if let delegate = self.motionDelegate {
                            delegate.motionUpdate(motion: motion)
                        }
                    }
                }
            }
        }
        
        if !playing && boxStartNode?.opacity == 1 {
            semaphoreStart.signal()
        }
    }
    
    
    func addElements() {
        let node = self.gameView.scene!.rootNode.childNode(withName: "nodes", recursively: false)
        self.gameView.scene!.rootNode.enumerateChildNodes { (node, _) in
            switch node.name {
            case "button1":
                button1 = node
            case "button2":
                button2 = node
            case "button3":
                button3 = node
            case "button4":
                button4 = node
            case "background":
                background = node
            case "capsule":
                boxStartNode = node
            case "pointsPlane":
                pointsPlaneNode = node
            case "pointer":
                pointerNode = node
            case "greenBox":
                greenBoxNode = node
            case "yellowBox":
                yellowBoxNode = node
            case "redBox":
                redBoxNode = node
            case "progressBar":
                progressBarNode = node
            case "recordBar":
                recordBarNode = node
            case "recordPlane":
                recordPlaneNode = node
            case "failedPlane":
                failedPlaneNode = node
            case "consecutivePlane":
                consecutivePlaneNode = node
            default: break
            }
        }
    }
    
    func replaceBackgroundImage() {
        var material = (background.geometry?.material(named: "Material"))!
        if let image = UIImage(named: "Art.scnassets/Images/" + song.author) {
            material.diffuse.contents = image
            background.geometry?.replaceMaterial(at: 0, with: material)
        }
    }
    
    
    
    func play(col: Int){
        
        DispatchQueue.main.async {
            switch col {
            case 1:
                self.soundEffect.guitar1()
                
            case 2:
                self.soundEffect.guitar2()
                
            case 3:
                self.soundEffect.guitar3()
                
            case 4:
               self.soundEffect.guitar4()
                
            default:
                break
            }
        }
    }
    
    func updatePoints() {
        DispatchQueue.main.async {
            if let node = self.pointText {
                node.removeFromParentNode()
            }
            if let node = self.multiplierNode {
                node.removeFromParentNode()
            }
            if let node = self.consecutivePointsNode {
                node.removeFromParentNode()
            }
            
            
            self.pointText = self.textManager.addTextAtPosition(str: "Points: \(self.points)", x: -4.7, y: 0.6, z: -1.7)
            self.pointText?.eulerAngles = SCNVector3(x: -0.26, y: 0.2, z: 0)
            
            self.multiplierNode = self.textManager.addTextAtPosition(str: "Multiplier: x\(self.multiplier)", x: -4.75, y: 0.3, z: -1.7)
            self.multiplierNode?.eulerAngles = SCNVector3(x: -0.26, y: 0.2, z: 0)
            
            self.consecutivePointsNode = self.textManager.addTextAtPosition(str: "Consecutives: \(self.consecutivePoints)", x: -4.8, y: 0.0, z: -1.7)
            self.consecutivePointsNode?.eulerAngles = SCNVector3(x: -0.26, y: 0.2, z: 0)
        }
    }
    
    func changePoints(point: Bool) {
        if !self.playing {
            return
        }
        
        if point {
            self.points += multiplier
        }
        
        pointerManager.modify(Up: point, actualPoints: self.points)
        
        if point {
            consecutivePoints += 1
        }
        else {
            consecutivePoints = 0
        }
        
        
        switch consecutivePoints {
        case 0:
            multiplier = 1
        case 10:
            multiplier = 2
            DispatchQueue(label: "points").async {
                self.consecutivePlaneNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Art.scnassets/Images/Scritta10")
                self.consecutivePlaneNode?.opacity = 1
                self.gameGuitarManager.fire()
                sleep(2)
                self.consecutivePlaneNode?.runAction(SCNAction.fadeOut(duration: 0.5))
            }
        case 20:
            multiplier = 3
            DispatchQueue(label: "points").async {
                self.consecutivePlaneNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Art.scnassets/Images/Scritta20")
                self.consecutivePlaneNode?.opacity = 1
                self.gameGuitarManager.fire()
                sleep(2)
                self.consecutivePlaneNode?.runAction(SCNAction.fadeOut(duration: 0.5))
            }
        case 30:
            multiplier = 4
            DispatchQueue(label: "points").async {
                self.consecutivePlaneNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Art.scnassets/Images/Scritta30")
                self.consecutivePlaneNode?.opacity = 1
                self.gameGuitarManager.fire()
                sleep(2)
                self.consecutivePlaneNode?.runAction(SCNAction.fadeOut(duration: 0.5))
            }
        case 40:
            DispatchQueue(label: "points").async {
                self.consecutivePlaneNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Art.scnassets/Images/Scritta40")
                self.consecutivePlaneNode?.opacity = 1
                self.gameGuitarManager.fire()
                sleep(2)
                self.consecutivePlaneNode?.runAction(SCNAction.fadeOut(duration: 0.5))
            }
        default:
            break
        }
    }
    
    
    func failed() {
        DispatchQueue(label: "failed", qos: .userInteractive).async {
            self.playing = false
            self.motionDelegate = nil
            self.soundEffect.booSound()
            self.failedPlaneNode?.runAction(SCNAction.group( [ SCNAction.fadeIn(duration: 0.3), SCNAction.move(by: SCNVector3(x: 0, y: 0, z: 2), duration: 0.4), SCNAction.rotateBy(x: 0, y: 0, z: 0.2, duration: 0.4) ] ))
            self.soundEffect.explosionSound()
            self.soundEffect.booSound()
            sleep(4)
            DispatchQueue.main.async {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    
    func sendSignalWhenClosing() {
        if let device = session.showConnectedDevices() {
            session.sendSignal(device[0], message: SignalCode.closeGamePhone)
        }
    }
    
    
}

extension GameViewController: SessionManagerDelegate {
    func mexReceived(_ manager: SessionManager, didMessageReceived: Int) {
        return
    }
    
    
    func peerFound(_ manger: SessionManager, peer: MCPeerID) {
        dictionary.addSample(peer: peer)
    }
    
    func peerLost(_ manager: SessionManager, peer lost: MCPeerID) {
        dictionary.removeSample(peer: lost)
    }
    
    
    func nearPeerHasChangedState(_ manager: SessionManager, peer change: MCPeerID, connected: Int) {
        DispatchQueue.main.async {
            if connected == 0 {
                DispatchQueue.main.async {
                    self.dismiss(animated: false, completion: nil)
                }
            }
        }
    }
    
    func mexReceived(_ manager: SessionManager, didMessageReceived: Array<String>) {
        
    }
    
    func mexReceived(_ manager: SessionManager, didMessageReceived: SignalCode) {
        DispatchQueue.main.async {
            
            switch didMessageReceived {
            
            case .closeGame: // Stop the game session
                self.dismiss(animated: false, completion: nil)
            
            case .signal:
                if self.button1Pressed {
                    self.play(col: 1)
                    self.gameGuitarManager.checkPoint(column: 1)
                }
                if self.button2Pressed {
                    self.play(col: 2)
                    self.gameGuitarManager.checkPoint(column: 2)
                }
                if self.button3Pressed {
                    self.play(col: 3)
                    self.gameGuitarManager.checkPoint(column: 3)
                }
                if self.button4Pressed {
                    self.play(col: 4)
                    self.gameGuitarManager.checkPoint(column: 4)
                }
                

            case .key1Pressed:
                self.button1.position.y = 0
                self.button1Pressed = true
            case .key2Pressed:
                self.button2.position.y = 0
                self.button2Pressed = true
            case .key3Pressed:
                self.button3.position.y = 0
                self.button3Pressed = true
            case .key4Pressed:
                self.button4.position.y = 0
                self.button4Pressed = true
                
            case .key1Released:
                self.button1.position.y = 0.05
                self.button1Pressed = false
            case .key2Released:
                self.button2.position.y = 0.05
                self.button2Pressed = false
            case .key3Released:
                self.button3.position.y = 0.05
                self.button3Pressed = false
            case .key4Released:
                self.button4.position.y = 0.05
                self.button4Pressed = false
                
            case .wah:
                if self.button1Pressed {
                    self.soundEffect.wah(column: 1)
                }
                if self.button2Pressed {
                    self.soundEffect.wah(column: 2)
                }
                if self.button3Pressed {
                    self.soundEffect.wah(column: 3)
                }
                if self.button4Pressed {
                    self.soundEffect.wah(column: 4)
                }
                
                
                
            // Add more cases here
            default:
                break
            }
        }
    }
}

extension GameViewController: ReactToMotionEvents {
    
    func motionUpdate(motion: GCMotion) {
        
        let motionAcceleration = motion.userAcceleration.y * motion.gravity.y + motion.userAcceleration.x * motion.gravity.x + motion.userAcceleration.z * motion.gravity.z
        
        
        if !movedController && -motionAcceleration > soundThreshold {
            
            movedController = true
            goodNote = false
            
            if button1Pressed {
                play(col: 1)
                self.gameGuitarManager.checkPoint(column: 1)
                goodNote = true
            }
            if button2Pressed {
                play(col: 2)
                self.gameGuitarManager.checkPoint(column: 2)
                goodNote = true
            }
            if button3Pressed {
                play(col: 3)
                self.gameGuitarManager.checkPoint(column: 3)
                goodNote = true
            }
            if button4Pressed {
                play(col: 4)
                self.gameGuitarManager.checkPoint(column: 4)
                goodNote = true
            }
            
            if !goodNote {
                changePoints(point: false)
            }
        }
        
        if movedController && motionAcceleration > 1.50  {
            movedController = false
        }
        
    }
}

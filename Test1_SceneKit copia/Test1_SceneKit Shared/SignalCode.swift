//
//  File.swift
//  Test1_SceneKit
//
//  Created by Giuseppe De Simone on 31/07/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//


enum SignalCode: UInt8 {
    
    // Main View
    case disconnectPeerSignal = 0
    case showAcousticGuitar = 1
    case showElectricGuitar = 2
    
    // Game
    case openGame = 3
    case closeGame = 4
    
    case signal1 = 5
    case signal2 = 6
    case signal3 = 7
    case signal4 = 8
    case key1Pressed = 11
    case key2Pressed = 12
    case key3Pressed = 13
    case key4Pressed = 14
    case key1Released = 15
    case key2Released = 16
    case key3Released = 17
    case key4Released = 18
}

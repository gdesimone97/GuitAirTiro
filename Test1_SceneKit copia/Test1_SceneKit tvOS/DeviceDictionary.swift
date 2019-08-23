//
//  DeviceDictionary.swift
//  Test1_SceneKit tvOS
//
//  Created by Gennaro Giaquinto on 26/07/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class DeviceDictionary {
    
    var dictionary = [MCPeerID : String]()
    var dim: Int { return dictionary.count }
    
    
    
    func name(peer: MCPeerID) -> String {
        return peer.displayName
    }
    
    func addSample(peer: MCPeerID) {
        if !isPresent(peer: peer) {
            dictionary[peer] = "\(dim+1)"
        }
    }
    
    func removeSample(peer: MCPeerID) {
        if isPresent(peer: peer) {
            scaleDict(peerRemoved: peer)
            dictionary.removeValue(forKey: peer)
        }
    }
    
    
    private func isPresent(peer: MCPeerID) -> Bool {
        for peers in dictionary {
            if peers.key == peer {
                return true
            }
        }
        return false
    }
    
    private func scaleDict(peerRemoved: MCPeerID) {
        for peer in dictionary {
            if Int(peer.value)! > Int(dictionary[peerRemoved]!)! {
                dictionary[peer.key] = String( Int(peer.value)! - 1 )
            }
        }
    }
    
    func keyForValue(value: String) -> MCPeerID? {
        for peer in dictionary {
            if peer.value == value {
                return peer.key
            }
        }
        return nil
    }
    
}

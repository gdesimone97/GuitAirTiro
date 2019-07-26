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
    
    var dictionary = [String : MCPeerID]()
    var dim: Int { return dictionary.count }
    
    
    
    func name(peer: MCPeerID) -> String {
        return peer.displayName
    }
    
    func addSample(peer: MCPeerID) {
        dictionary["\(dim+1)"] = peer
    }
    
    func removeSample(peer: MCPeerID) {
        let peerLostKey = findValue(peer: peer)
        if peerLostKey != "nil" {
            dictionary.removeValue(forKey: peerLostKey)
        }
    }
    
    
    private func findValue(peer: MCPeerID) -> String {
        for key in dictionary.keys {
            if dictionary[key] == peer {
                return key
            }
        }
        return "nil"
    }
    
}

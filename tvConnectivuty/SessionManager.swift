//
//  SessionManager.swift
//  tvConnectivity iOS
//
//  Created by Giuseppe De Simone on 24/07/2019.
//  Copyright © 2019 Giuseppe De Simone. All rights reserved.
//

import UIKit
import MultipeerConnectivity

enum MyError: Error {
    case notPeerFound
}

@objc protocol SessionManagerDelegate: class {
    func peerFound(_ manger: SessionManager, peer: MCPeerID)
    @objc optional func nearPeerHasChangedState(_ manager: SessionManager,peer: MCPeerID, connected: Bool)
    @objc optional func mexReceived(_ manager: SessionManager,didMessaggeReceived: UInt8)
    @objc optional func peerLost(_ manager: SessionManager, peerIdString: MCPeerID)
}

class SessionManager: NSObject {
    // Initiating a Session
    private var peerID = MCPeerID(displayName: UIDevice.current.name ) // ID peer ugaule all'identificativo del device
    
    lazy var session: MCSession = {
        let mySession = MCSession(peer: self.peerID)
        mySession.delegate = self
        return mySession
    }()
    
    private let typeOfService = "guit-air"
    weak var delegate: SessionManagerDelegate?
    private let serviceBrowser: MCNearbyServiceBrowser
    private let serviceAdverticer: MCNearbyServiceAdvertiser
    
    //    Singleton
    static var share = SessionManager()
    
    override init() {
        self.serviceBrowser = MCNearbyServiceBrowser(peer: self.peerID, serviceType: typeOfService) // Cerca altri peer usando l'infrastrutture di rete disponibili
        self.serviceAdverticer = MCNearbyServiceAdvertiser(peer: self.peerID, discoveryInfo: nil, serviceType: typeOfService) // Gestisce gli invita da parte degli altri peer
        super.init()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
        
        self.serviceAdverticer.delegate = self
        self.serviceAdverticer.startAdvertisingPeer()
    }
    
    deinit {
        self.serviceBrowser.stopBrowsingForPeers()
        self.serviceAdverticer.stopAdvertisingPeer()
    }
    
    func invitePeer(invite peer: MCPeerID) throws {
        self.serviceBrowser.invitePeer(peer, to: self.session, withContext: nil, timeout: 30)
    }
    
    
    #if os(iOS)
    func sendSignal (_ peer: MCPeerID, message: UInt8) {
        var mex = message
        if self.session.connectedPeers.count > 0 {
            print("Messaggio inviato")
            let data = withUnsafeBytes(of: &mex) { Data($0) }
            do {
                try self.session.send(data, toPeers: [peer], with: .unreliable)
            }
            catch _ {
                print("Errore invio messaggio")
            }
        }
    }
    #endif
    
    /**
     Funzione che ritorna la lista dei dispositivi connessi
     Restituisce nil se non ci sono dispositivi connessi
     */
    func showConncetedDevices() -> Array<MCPeerID>? {
        let deviceList: Array<MCPeerID> = session.connectedPeers
        guard deviceList.count != 0 else { return nil }
        return deviceList
    }
}

extension SessionManager: MCSessionDelegate {
    // Lo stato di un peer vicino è cambiato
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        state == MCSessionState.connected ? self.delegate?.nearPeerHasChangedState?(self,peer: peerID,connected: true) : self.delegate?.nearPeerHasChangedState?(self,peer:peerID, connected: false)
        print("Stato della connessione: \(state.rawValue)")
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Messaggio ricevuto da: \(peerID), messaggio: \(data)")
        
        let intData = data.first
        self.delegate?.mexReceived?(self, didMessaggeReceived: intData!)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        return
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        return
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        return
    }
}

extension SessionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("peer trovato: \(peerID.displayName) ; \(peerID)")
        
        self.delegate?.peerFound(self, peer: peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("peer perso: \(peerID)")
        self.delegate?.peerLost?(self, peerIdString: peerID)
    }
}

extension SessionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        print("Invito ricevuto da: \(peerID)")
        #if os(iOS)
        invitationHandler(true,self.session)
        #endif
        
    }
}
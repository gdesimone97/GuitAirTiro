//
//  SessionManager.swift
//  tvConnectivity iOS
//
//  Created by Giuseppe De Simone on 24/07/2019.
//  Copyright © 2019 Giuseppe De Simone. All rights reserved.
//

import UIKit
import MultipeerConnectivity

@objc protocol SessionManagerDelegate: class {
    func nearPeerHasChangedState(_ manager: SessionManager, connected state: Bool)
    @objc optional func mexReceived(_ manager: SessionManager,didMessaggeReceived: Data)
    @objc optional func peerLost(_ manager: SessionManager, peerIdString: String)
}


class SessionManager: NSObject {
    // Initiating a Session
    private var peerID = MCPeerID(displayName: "phone-" + UIDevice.current.name ) // ID peer ugaule all'identificativo del device
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
        self.serviceBrowser = MCNearbyServiceBrowser(peer: self.peerID, serviceType: typeOfService) // Cerca altri peer usando l'instrastrutture di rete disponibili
        self.serviceAdverticer = MCNearbyServiceAdvertiser(peer: self.peerID, discoveryInfo: nil, serviceType: typeOfService) // Gestisce gli inviti da parte degli altri peer
        super.init()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
        
        self.serviceAdverticer.delegate = self
        self.serviceAdverticer.startAdvertisingPeer()
        print(peerID.displayName)
    }
    
    deinit {
        print("Deallocato")
        self.serviceBrowser.stopBrowsingForPeers()
        self.serviceAdverticer.stopAdvertisingPeer()
    }
    
    func sendSignal (mex: Int8) {
        var messaggio = mex
        let peerList = session.connectedPeers
        if peerList.count > 0 {
            print("Messaggio inviato")
            let data = withUnsafeBytes(of: &messaggio) {Data($0)}
            do {
             try self.session.send(data, toPeers: peerList, with: .unreliable)
        }
            catch _{
                print("Errore Invio messaggio")
            }
        }
    }
    
}

extension SessionManager: MCSessionDelegate {
    // Lo stato di un peer vicino è cambiato
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        state == MCSessionState.connected ? self.delegate?.nearPeerHasChangedState(self,connected: true) : self.delegate?.nearPeerHasChangedState(self,connected: false)
        print("Stato della connessione: \(state.rawValue)")
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        return
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
        print("peer trovato: \(peerID)")
//        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 30)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("peer perso: \(peerID)")
        self.delegate?.peerLost?(self, peerIdString: peerID.displayName)
    }
}

extension SessionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Invito ricevuto da: \(peerID)")
        invitationHandler(true,self.session)
    }
}

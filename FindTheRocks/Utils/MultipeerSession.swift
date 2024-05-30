/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 A simple abstraction of the MultipeerConnectivity API as used in this app.
 */

import Foundation
import MultipeerConnectivity

/// - Tag: MultipeerSession
@Observable
class MultipeerSession: NSObject {
    static let serviceType = "find-the-rock"
    
    private var displayName:String
    private var myPeerID:MCPeerID
    private var session: MCSession!
    private var serviceAdvertiser: MCNearbyServiceAdvertiser!
    private var serviceBrowser: MCNearbyServiceBrowser!
    private var nearbyPeers: [Player] = []
    
    private let receivedDataHandler: (Data, MCPeerID) -> Void
    
    /// - Tag: MultipeerSetup
    init(displayName:String,receivedDataHandler: @escaping (Data, MCPeerID) -> Void ) {
        self.displayName = displayName
        self.receivedDataHandler = receivedDataHandler
        self.myPeerID = MCPeerID(displayName: displayName)
        
        super.init()
        
        setupSession()
        startAdvertisingAndBrowsing()
    }
    
    func sendToAllPeers(_ data: Data) {
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("error sending data to peers: \(error.localizedDescription)")
        }
    }
    
    func notifyPeer(peer: MCPeerID, data: Data) {
        do {
            try session.send(data, toPeers: [peer], with: .reliable)
        } catch {
            print("error sending data to peers: \(error.localizedDescription)")
        }
    }
    
    var connectedPeers: [MCPeerID] {
        return session.connectedPeers
    }
    
    var detectedPeers: [Player] {
        return nearbyPeers
    }
    
    private func setupSession(){
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
    }
    
    private func startAdvertisingAndBrowsing() {
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: MultipeerSession.serviceType)
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: MultipeerSession.serviceType)
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
    }
    
    private func stopAdvertisingAndBrowsing() {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }
    
    func updateDisplayName(_ newDisplayName: String) {
        stopAdvertisingAndBrowsing()
        
        displayName = newDisplayName
        myPeerID = MCPeerID(displayName: newDisplayName)
        
        setupSession()
        startAdvertisingAndBrowsing()
    }
}

extension MultipeerSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        // not used
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        receivedDataHandler(data, peerID)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        fatalError("This service does not send/receive streams.")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        fatalError("This service does not send/receive resources.")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        fatalError("This service does not send/receive resources.")
    }
    
}

extension MultipeerSession: MCNearbyServiceBrowserDelegate {
    
    /// - Tag: FoundPeer
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        // Invite the new peer to the session.
        
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
        
        print(nearbyPeers.firstIndex(where: {$0.peerID == peerID}) == nil)
        if nearbyPeers.firstIndex(where: { $0.peerID == peerID }) == nil {
            print("masuk")
            nearbyPeers.append(Player(peerID: peerID, profile: "", status: .disconnected, point: 0))
        }
        print(self.nearbyPeers)
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // This app doesn't do anything with non-invited peers, so there's nothing to do here.
        print("lost peer: ", peerID)
        
        if let index = nearbyPeers.firstIndex(where: {$0.peerID == peerID}) {
            nearbyPeers.remove(at: index)
        }
    }
    
}

extension MultipeerSession: MCNearbyServiceAdvertiserDelegate {
    
    /// - Tag: AcceptInvite
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Call handler to accept invitation and join the session.
        invitationHandler(true, self.session)
    }
    
}

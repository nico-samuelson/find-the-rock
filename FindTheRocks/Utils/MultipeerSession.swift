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
    private var myPeerID:MCPeerID!
    private var session: MCSession!
    private var serviceAdvertiser: MCNearbyServiceAdvertiser!
    private var serviceBrowser: MCNearbyServiceBrowser!
    private var nearbyPeers: [Player] = []
    var showInviteModal: ((String,MCPeerID, @escaping (Bool)->Void) -> Void)?
    var confirmingRes: (()->Bool)?
//    private let receivedDataHandler: (Data, MCPeerID) -> Void
    
    /// - Tag: MultipeerSetup
    init(displayName:String) {
        self.displayName = displayName
//        self.receivedDataHandler = receivedDataHandler
        self.myPeerID = MCPeerID(displayName: displayName)
        
        super.init()
        
        setupSession()
        startAdvertisingAndBrowsing()
    }
    
    func getDisplayName() -> String {
        return self.displayName
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
        serviceAdvertiser.delegate = nil
        serviceBrowser.stopBrowsingForPeers()
        serviceBrowser.delegate = nil
    }
    
    func updateDisplayName(_ newDisplayName: String) {
//        session.delegate = nil
//        session.disconnect()
        stopAdvertisingAndBrowsing()
        
//        self.session = nil
//        self.myPeerID = nil
//        self.serviceBrowser = nil
//        self.serviceAdvertiser = nil
        
        // start updating the new name
        self.displayName = newDisplayName
        self.myPeerID = MCPeerID(displayName: newDisplayName)
        
//        self.setupSession()
        self.startAdvertisingAndBrowsing()
    }
    
    func invitePeer(peerID: MCPeerID, data: Data) {
        serviceBrowser.invitePeer(peerID, to: self.session, withContext: data, timeout: 10)
    }
}

extension MultipeerSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            print("not connected")
        case .connecting:
            print("connecting")
        case .connected:
            print("connected")
//            print(self.connectedPeers)
        @unknown default:
            print("Unknown error")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
//            if let data = try NSKeyedUnarchiver.unarchivedObject(ofClass: Player.self, from: data) {
//                print(data.peerID.displayName)
//            }
            
            if let data = String(data: data, encoding: .utf8) {
                if data == "disconnected" {
                    serviceBrowser.stopBrowsingForPeers()
                    serviceAdvertiser.stopAdvertisingPeer()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        self.serviceBrowser.startBrowsingForPeers()
                        self.serviceBrowser.stopBrowsingForPeers()
                    }
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        
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
        
//        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
        
        
        DispatchQueue.main.async {
//            self.nearbyPeers.removeAll()
            print(self.nearbyPeers.firstIndex(where: {$0.peerID == peerID}) == nil)
            if self.nearbyPeers.firstIndex(where: { $0.peerID == peerID }) == nil {
                self.nearbyPeers.append(Player(peerID: peerID, profile: "", status: .disconnected, point: 0))
            }
            print(self.nearbyPeers.map({($0.peerID, $0.peerID.displayName)}))
        }
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // This app doesn't do anything with non-invited peers, so there's nothing to do here.
        DispatchQueue.main.async {
            print("lost peer: ", peerID)
            
            if let index = self.nearbyPeers.firstIndex(where: {$0.peerID == peerID}) {
                self.nearbyPeers.remove(at: index)
            }
            print("after lost: ", self.nearbyPeers.map({($0.peerID, $0.peerID.displayName)}))
        }
        
    }
    
}

extension MultipeerSession: MCNearbyServiceAdvertiserDelegate {
    
    
    /// - Tag: AcceptInvite
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
//        Open the modal dialog and use the callback
        
        guard let context = context else { return }
        
        if let contextString = String(data: context, encoding: .utf8) {
            print("before connected",self.session.connectedPeers.map({$0.displayName}))
            showInviteModal?(contextString, peerID, { accepted in
                print("accepted: ", accepted)
                invitationHandler(accepted, self.session)
                print("after connected",self.session.connectedPeers.map({$0.displayName}))
            })
        }
    }
    
}

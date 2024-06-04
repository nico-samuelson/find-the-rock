/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 A simple abstraction of the MultipeerConnectivity API as used in this app.
 */

import Foundation
import MultipeerConnectivity
import ARKit

/// - Tag: MultipeerSession
@Observable
class MultipeerSession: NSObject {
    static let serviceType = "find-the-rock"
    
    var displayName:String = "Player"
    private var myPeerID:MCPeerID!
    private var session: MCSession!
    private var serviceAdvertiser: MCNearbyServiceAdvertiser!
    private var serviceBrowser: MCNearbyServiceBrowser!
    private var nearbyPeers: [Player] = []
    private var isMaster:Bool = false
    private var isJoined:Bool = false
    var showInviteModal: ((String,MCPeerID, @escaping (Bool)->Void) -> Void)?
    var showDestroyModal: ((String)->Void)?
    var confirmingRes: (()->Bool)?
    var room: Room = Room()
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
        stopAdvertisingAndBrowsing()
        
        // start updating the new name
        self.displayName = newDisplayName
        self.myPeerID = MCPeerID(displayName: newDisplayName)
        
        self.setupSession()
        self.startAdvertisingAndBrowsing()
    }
    
    func invitePeer(peerID: MCPeerID, data: Data) {
        serviceBrowser.invitePeer(peerID, to: self.session, withContext: data, timeout: 15)
    }
    
    func createRoom(){
        serviceAdvertiser.stopAdvertisingPeer()
        serviceAdvertiser.delegate = nil
        
        // Create room id
        self.room.name = "\(displayName) \(Int.random(in:1...100))"
        self.isMaster = true
        self.isJoined = true
        
        // new advertiser and run
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer:self.myPeerID,discoveryInfo: ["room":self.room.name],serviceType: serviceBrowser.serviceType)
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
    }
    
    func joinRoom(){
        serviceAdvertiser.stopAdvertisingPeer()
        serviceAdvertiser.delegate = nil

        serviceAdvertiser = MCNearbyServiceAdvertiser(peer:self.myPeerID,discoveryInfo: ["room":self.room.name],serviceType: serviceBrowser.serviceType)
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        self.isJoined = true
    }
    
    func destroyRoom(){
        // Send to all peers to destroy itself
        print("sending destroyed")
        sendToAllPeers("destroyed".data(using:.utf8)!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.quitRoom()
                    self.isMaster = false
                }
    }
    
    func quitRoom(){
        print("quitting room")
        self.session.disconnect()
        self.nearbyPeers = []
        self.room = Room()
        // change the session advertising
        self.stopAdvertisingAndBrowsing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.setupSession()
            self.startAdvertisingAndBrowsing()
        }
        
        self.isJoined = true
    }
    
    func syncRoom(){
        self.sendToAllPeers(try! NSKeyedArchiver.archivedData(withRootObject: self.room, requiringSecureCoding: true))
    }
    
    func getPeerId() -> MCPeerID {
        return self.myPeerID
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
            // if room master than share the state room to every connected player
            print("Connected with \(peerID.displayName)")
            if let index = self.nearbyPeers.firstIndex(where: {$0.peerID == peerID}) {
                self.nearbyPeers[index].status = .connected
            }
            if isMaster {
                // Assign the connected players into a room
                let team1Count = self.room.teams[0].players.count
                let team2Count = self.room.teams[1].players.count
                let target = team1Count <= team2Count ? 0 : 1
                
                self.room.teams[target].players.append(Player(peerID:peerID,profile:"tigreal-avatar",status:.connected,point:0))
                self.sendToAllPeers( try! NSKeyedArchiver.archivedData(withRootObject: self.room ,requiringSecureCoding: true))
                
            }
            print("detected",self.detectedPeers.map({($0.peerID,$0.peerID.displayName,$0.status)}))
        @unknown default:
            print("Unknown error")
        }
    }
    
    func handleDataRoom(_ newRoom: Room){
        print("receiving room")
        self.room.name = newRoom.name
        self.room.teams = newRoom.teams
        self.room.fakeRock = newRoom.fakeRock
        self.room.hideTime = newRoom.hideTime
        self.room.realRock = newRoom.realRock
        self.room.seekTime = newRoom.seekTime
        
        if !self.isJoined {
            self.joinRoom()
        }
    }
    
    func handleDataString(_ string: String){
        print("received \(string)")
        if string == "kicked" {
            print("quitting from room")
            self.showDestroyModal?("kicked")
            self.quitRoom()
        }
        
        if string == "destroyed" {
            print("quitting from room")
            self.showDestroyModal?("destroy")
            self.quitRoom()
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            if let plainData = data as? Data, let string = String(data: plainData, encoding: .utf8) {
                handleDataString(string)
            } else {
                let object = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [Room.self, Player.self, Team.self, Rock.self, MCPeerID.self, NSString.self, ARAnchor.self, SCNNode.self, NSArray.self], from: data)
                
                switch object {
                case let string as String:
                    handleDataString(string)
                case let room as Room:
                    handleDataRoom(room)
                case let data as Data:
                    handleDataString(String(decoding: data, as: UTF8.self))
                default:
                    print("Undetected data type!")
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
        // check for discoveryInfo
        if let info = info {
            // if exist the same room and connected peers, and not connected yet
            if self.room.name == info["room"]! && (self.connectedPeers.firstIndex(where: { $0 == peerID }) == nil) {
                browser.invitePeer(peerID,to:self.session,withContext:"approved".data(using:.utf8),timeout:10)
            }
        }
        
        DispatchQueue.main.async {
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
            print("lost peer: ", peerID, peerID.displayName)
            
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
        
        if let plainData = context as? Data, let string = String(data: plainData, encoding: .utf8) {
            handleDataString(string)
        } else {
            let object = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [Room.self, Player.self, Team.self, Rock.self, MCPeerID.self, NSString.self, ARAnchor.self, SCNNode.self, NSArray.self], from: context)
            
            switch object {
            case let string as NSString:
                handleInvitationString(text: string, invitationHandler: invitationHandler)
            case let player as Player:
                handleInvitationPlayer(peer: peerID, player: player, invitationHandler: invitationHandler)
            default:
                print("Undetected data type!")
            }
        }
        
    }
    
    func handleInvitationString(text: NSString,invitationHandler: @escaping (Bool, MCSession?) -> Void){
        if text == "approved"{
            invitationHandler(true,self.session)
        }
    }
    
    func handleInvitationPlayer(peer: MCPeerID, player: Player,invitationHandler: @escaping (Bool, MCSession?) -> Void){
        showInviteModal?(player.profile, peer, { accepted in
            print(accepted)
            invitationHandler(accepted, self.session)
        })
    }
}

extension MCPeerID: NSSecureCoding {
    public static var supportsSecureCoding: Bool = true
}

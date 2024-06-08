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
    var isMaster: Bool = false
    private var isJoined:Bool = false
    var showInviteModal: ((String,MCPeerID, @escaping (Bool)->Void) -> Void)?
    var showDestroyModal: ((String)->Void)?
    var confirmingRes: (()->Bool)?
    var room: Room! = Room()
    var isPlantingFakeRock: Bool = false
    var isPlanting: Bool = true
    var isGameStarted: Bool = false
    var plantTurn: Int = 0
    
    // MARK: Scene View
    var cameraTransform: SCNMatrix4? = SCNMatrix4()
    var cameraPosition: SCNVector3? = SCNVector3(x: 0, y: 0, z: 0)
    var sceneView: ARSCNView! = {
        let sceneView = ARSCNView()
        
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        return sceneView
    }()
    
    var mappingStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Mapping"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        
        return label
    }()
    
    /// - Tag: MultipeerSetup
    init(displayName:String) {
        self.displayName = displayName
        self.myPeerID = MCPeerID(displayName: displayName)
        super.init()
        
        setupSession()
        startAdvertisingAndBrowsing()
    }
    
    func getDisplayName() -> String {
        return self.displayName
    }
    
    func sendToAllPeers(_ data: Data) {
        //        print("connected: ", self.session.connectedPeers)
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
    
    var peerID: MCPeerID {
        return myPeerID
    }
    
    func getTeam(_ peerID: MCPeerID?) -> Int {
        var myTeam = 1
        
        if self.room.teams[0].players.map({ $0.peerID }).contains(peerID ?? self.peerID) {
            myTeam = 0
        }
        else if self.room.teams[1].players.map({ $0.peerID }).contains(peerID ?? self.peerID) {
            myTeam = 1
        }
        
        return myTeam
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
        // re-sync team planter
        for team in self.room.teams where team.players.count > 0 {
            for player in team.players where player.isPlanter {
                player.isPlanter = false
            }
            team.players[0].isPlanter = true
        }
        
        self.sendToAllPeers(try! NSKeyedArchiver.archivedData(withRootObject: self.room, requiringSecureCoding: true))
    }
    
    func getPeerId() -> MCPeerID {
        return self.myPeerID
    }
    
    func disconnect() {
        serviceBrowser.stopBrowsingForPeers()
        serviceAdvertiser.stopAdvertisingPeer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.serviceBrowser.startBrowsingForPeers()
            self.serviceBrowser.stopBrowsingForPeers()
        }
    }
}

// MARK: Received Data Handler
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
                
                self.room.teams[target].players.append(Player(peerID:peerID,profile:"tigreal-avatar",status:.connected,point:0, isPlanter: true))
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
        
        if string == "start" {
            self.isGameStarted = true
        }
    }
    
    // room master will merge all the anchors sent by the players
    func handleAnchorChange(_ newAnchor: ARAnchor, _ mode: String, _ isReal: Bool, _ sender: MCPeerID) {
        let team = self.getTeam(sender)
        // TODO: change send world map only for adding and removing
//        guard isMaster else { return }
        if mode == "pick" {
            guard isReal, let player = room.teams[team].players.first(where: {$0.peerID == sender}) else { return }
            player.point += 1
            room.teams[team].realPlanted.removeAll(where: {$0.anchor.name == newAnchor.name})
            sceneView.session.remove(anchor: newAnchor)
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: CustomAnchor(anchor:newAnchor,action: "pick", isReal: isReal),requiringSecureCoding: true) else { fatalError("can't encode anchor") }
                    self.sendToAllPeers(data)
            
            // send the removed anchor to the others peer
            
        } else {
            if mode == "add" {
                if (isReal && room.teams[team].realPlanted.count + 1 <= room.realRock) {
                    room.teams[team].realPlanted.append(Rock(isFake: !isReal, anchor: newAnchor))
                    sceneView.session.add(anchor: newAnchor)
                }
                else if (!isReal && room.teams[team].fakePlanted.count + 1 <= room.fakeRock){
                    room.teams[team].fakePlanted.append(Rock(isFake: !isReal, anchor: newAnchor))
                    sceneView.session.add(anchor: newAnchor)
                }
            }
            else if mode == "remove" {
                print("remove node")
                print(isReal)
                print(room.teams[team].realPlanted)
                if isReal && room.teams[team].realPlanted.count > 0 {
                    print(room.teams[team].realPlanted.count)
                    room.teams[team].realPlanted.removeAll(where: {$0.anchor.identifier == newAnchor.identifier})
                    print(room.teams[team].realPlanted.count)
                    sceneView.session.remove(anchor: newAnchor)
                }
                else if !isReal && room.teams[team].fakePlanted.count > 0 {
                    room.teams[team].fakePlanted.removeAll(where: {$0.anchor.identifier == newAnchor.identifier})
                    sceneView.session.remove(anchor: newAnchor)
                }
            }
            
            // TODO: make the pick sending the anchor to picked
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.sceneView.session.getCurrentWorldMap { worldMap, error in
                    guard let map = worldMap
                    else { print("Error: \(error!)"); return }
                    guard let data = try? NSKeyedArchiver.archivedData(withRootObject: ARData(room: self.room, map: map), requiringSecureCoding: true)
                    else { fatalError("can't encode map") }
                    self.sendToAllPeers(data)
                }
            }
        }
    }
    
    // players will receive the world map from master
    func receiveWorldMap(data: ARData) {
//        if (!isMaster) {
            print("receive new world map and room data")
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal, .vertical]
            configuration.initialWorldMap = data.map
//            configuration.initialWorldMap?.anchors.removeAll()
//            configuration.worldAlignment = .gravityAndHeading
            
            self.room = data.room
            self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func receivePick(_ customAnchor: CustomAnchor,_ peerID: MCPeerID){
        let team = self.getTeam(peerID)
        guard customAnchor.isReal, let player = room.teams[team].players.first(where: {$0.peerID == peerID}) else { return }
        player.point += 1
        room.teams[team].realPlanted.removeAll(where: {$0.anchor.name == customAnchor.anchor.name})
        sceneView.session.remove(anchor: customAnchor.anchor)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            if let plainData = data as? Data, let string = String(data: plainData, encoding: .utf8) {
                handleDataString(string)
            } else {
                let object = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [Room.self, Player.self, Team.self, Rock.self, CustomAnchor.self, ARData.self, ARWorldMap.self, ARSession.CollaborationData.self, MCPeerID.self, NSString.self, ARAnchor.self, SCNNode.self, NSArray.self], from: data)
                
                switch object {
                case let string as String:
                    handleDataString(string)
                case let room as Room:
                    handleDataRoom(room)
                case let newAnchor as CustomAnchor:
                    if newAnchor.action != "pick" {
                        handleAnchorChange(newAnchor.anchor, newAnchor.action, newAnchor.isReal, peerID)
                    }else{
                        // action to delete locally and not changing the world map globally
                       receivePick(newAnchor, peerID)
                    }
                case let arData as ARData:
                    receiveWorldMap(data: arData)
                case let data as Data:
                    handleDataString(String(decoding: data, as: UTF8.self))
                default:
                    print("unknown type received")
                }
            }
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

// MARK: Browser
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
               self.nearbyPeers.append(Player(peerID: peerID, profile: "", status: .disconnected, point: 0, isPlanter: false))
           }
           print(self.nearbyPeers.map({($0.peerID, $0.peerID.displayName)}))
       }
    }
    
    /// - Tag: Lost Peer
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
        DispatchQueue.main.async {
            if let index = self.nearbyPeers.firstIndex(where: {$0.peerID == peerID}) {
                self.nearbyPeers.remove(at: index)
            }
            // Changing the room teams
            if self.isMaster {
                for x in 0...1 {
                    if let index = self.room.teams[x].players.firstIndex(where: {$0.peerID == peerID}){
                        self.room.teams[x].players.remove(at: index)
                    }
                }
                self.syncRoom()
            }
        }
        
    }
    
}

// MARK: Advertiser
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

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
    private var displayName:String
    private var myPeerID:MCPeerID!
    private var session: MCSession!
    private var serviceAdvertiser: MCNearbyServiceAdvertiser!
    private var serviceBrowser: MCNearbyServiceBrowser!
    private var nearbyPeers: [Player] = []
    var showInviteModal: ((String,MCPeerID, @escaping (Bool)->Void) -> Void)?
    var confirmingRes: (()->Bool)?
    var room: Room! = Room()
    var isUpdatingWorldMap: Bool = false
    var isPlantingFakeRock: Bool = false
    
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
        
        self.room.teams[1].players.append(Player(peerID: self.myPeerID, profile: "default", status: .disconnected, point: 0))
        
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
    
    func sendARData(_ data : Data, completion: @escaping (Bool) -> Void) {
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            completion(isUpdatingWorldMap)
        } catch {
            print("error sending data to peers: \(error.localizedDescription)")
            completion(false)
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
    
    func getMyTeam() -> Int {
        var myTeam = 1
        
        if self.room.teams[0].players.map({ $0.peerID }).contains(self.peerID) {
            myTeam = 0
        }
        else if self.room.teams[1].players.map({ $0.peerID }).contains(self.peerID) {
            myTeam = 1
        }
        
//        print("my team: ", myTeam)
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
        //        serviceAdvertiser.discoveryInfo = ["code": "room 1"]
        
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
        
        self.setupSession()
        self.startAdvertisingAndBrowsing()
    }
    
    func invitePeer(peerID: MCPeerID, data: Data) {
        serviceBrowser.invitePeer(peerID, to: self.session, withContext: data, timeout: 15)
    }
    
    func createRoom(){
        serviceAdvertiser.stopAdvertisingPeer()
        serviceAdvertiser.delegate = nil
        
        //        Create room id
        self.room = displayName.isEmpty ? Room() : Room(name:"\(displayName) \(Int.random(in:1...100))")
        
        //        new advertiser and run
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer:self.myPeerID,discoveryInfo: ["room":self.room.name],serviceType: serviceBrowser.serviceType)
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
    }
    func getPeerId() -> MCPeerID {
        return self.myPeerID
    }
    
    func disconnect() {
//        if data == "disconnected" {
            serviceBrowser.stopBrowsingForPeers()
            serviceAdvertiser.stopAdvertisingPeer()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.serviceBrowser.startBrowsingForPeers()
                self.serviceBrowser.stopBrowsingForPeers()
            }
//        }
    }
    
    
    func alignNewAnchor(anchor: ARAnchor) -> ARAnchor? {
        guard let currentFrame = sceneView.session.currentFrame else {
            print("Couldn't get current frame")
            return nil
        }
        
        // Get current device transform (position and orientation)
        let currentTransform = currentFrame.camera.transform

        // Extract the translation and rotation components of the current transform
        let currentTranslation = currentTransform.columns.3
        let currentRotation = simd_quatf(currentTransform)

        // Extract the translation and rotation components of the received anchor's transform
        let anchorTranslation = anchor.transform.columns.3
        let anchorRotation = simd_quatf(anchor.transform)

        // Calculate the new position: your current position + the relative position of the anchor
        let newTranslation = currentTranslation + anchorTranslation

        // Combine the rotations: your current rotation * anchor's rotation
        let newRotation = currentRotation * anchorRotation

        // Construct the new transform with the combined translation and rotation
        var newTransform = matrix_identity_float4x4
        newTransform.columns.3 = newTranslation
        newTransform = matrix_float4x4(newRotation)
        newTransform.columns.3 = newTranslation
        
//        print(anchor.name)

        // Create a new anchor with the transformed position and orientation
        let newAnchor = ARAnchor(name: anchor.name!, transform: anchor.transform)
        
        return newAnchor
    }
    
    func setWorldMap(map: ARWorldMap) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.initialWorldMap = map
        configuration.worldAlignment = .gravityAndHeading
        
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
//        print("map rock name: ", sceneView.session.currentFrame?.anchors.map { $0.name})
//        print("map rock transform: ", sceneView.session.currentFrame?.anchors.map {$0.transform})
//        print("received from map rock identifier: ", map.anchors.map {$0.identifier})
//        print("initial world rock transform: ", configuration.initialWorldMap?.anchors.map {$0.transform})
//        print("rock identifier: ", self.room.teams[1].realPlanted[0].anchor.identifier)
//        print("rock transform: ", self.room.teams[1].realPlanted[0].anchor.transform)
        
        let allRocks = self.room.teams[0].fakePlanted + self.room.teams[0].realPlanted + self.room.teams[1].fakePlanted + self.room.teams[1].realPlanted
        
//        scene
        
//        if let anchors = configuration.initialWorldMap?.anchors {
            for rock in allRocks {
//                print("rock transform: ", rock.anchor.transform)
//                print("Map rock transform: ", map.anchors.first(where: {$0.identifier == rock.anchor.identifier})?.transform)
//                print("AR frame rock transform: ", sceneView.session.currentFrame?.anchors.first(where: {$0.identifier == rock.anchor.identifier})?.transform)
                if let name = rock.anchor.name, name.hasPrefix("rock"), let newAnchor = alignNewAnchor(anchor: rock.anchor) {
                    sceneView.session.add(anchor: newAnchor)
                    
                    //                    sceneView.session.currentFrame?.anchors.removeAll(where: { $0.identifier == anchor.identifier })
                    //                    configuration.initialWorldMap?.anchors.removeAll(where: { $0.identifier == anchor.identifier })
                }
            }
//        }
    }
    
    func receiveCollaborationData(_ collaborationData: ARSession.CollaborationData) {
        print("received collaboration data")
//        collaborationData.
        self.sceneView.session.update(with: collaborationData)
        
//        guard let anchors = sceneView.session.currentFrame?.anchors else { return }
//        for anchor in anchors {
//            
//        }
    }
//    func receive
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
            print("connected")
        @unknown default:
            print("Unknown error")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            print(data)
            //            if let data = try NSKeyedUnarchiver.unarchivedObject(ofClass: Player.self, from: data) {
            //                print(data.peerID.displayName)
            //            }
            
            let object = try! NSKeyedUnarchiver.unarchivedObject(ofClasses: [Room.self, Player.self, Team.self, Rock.self, ARWorldMap.self, ARSession.CollaborationData.self, MCPeerID.self, NSString.self, ARAnchor.self, SCNNode.self, NSArray.self], from: data)
            
            switch object {
            case let message as String:
                disconnect()
//            case let anchor as ARAnchor:
//                addNewObject(anchor: anchor)
            case let newRoom as Room:
                if (!isUpdatingWorldMap) {
                    self.isUpdatingWorldMap = true
                    self.room = newRoom
                    self.isUpdatingWorldMap = false
                }
                
            case let map as ARWorldMap:
//                print("able to receive map: ", !self.isUpdatingWorldMap)
                if (!isUpdatingWorldMap) {
                    self.isUpdatingWorldMap = true
                    setWorldMap(map: map)
                    self.isUpdatingWorldMap = false
                }
//            case let collaborationData as ARSession.CollaborationData:
//                self.isUpdatingWorldMap = true
//                receiveCollaborationData(collaborationData)
//                self.isUpdatingWorldMap = false
            default:
                print("unknown type received")
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

// MARK: Browser
extension MultipeerSession: MCNearbyServiceBrowserDelegate {
    
    /// - Tag: FoundPeer
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        // check for discoveryInfo
        
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
//        if let info = info {
//            //            if exist the same room and connected peers, and not connected yet
//            if self.room.name == info["room"]! && (self.connectedPeers.firstIndex(where: { $0 == peerID }) == nil) {
//                browser.invitePeer(peerID,to:self.session,withContext:"approved".data(using:.utf8),timeout:10)
//            }
//        }
//        
//        DispatchQueue.main.async {
//            //            self.nearbyPeers.removeAll()
//            print(self.nearbyPeers.firstIndex(where: {$0.peerID == peerID}) == nil)
//            if self.nearbyPeers.firstIndex(where: { $0.peerID == peerID }) == nil {
//                self.nearbyPeers.append(Player(peerID: peerID, profile: "", status: .disconnected, point: 0))
//            }
//            print(self.nearbyPeers.map({($0.peerID, $0.peerID.displayName)}))
//        }
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // This app doesn't do anything with non-invited peers, so there's nothing to do here.
        DispatchQueue.main.async {
//            print("lost peer: ", peerID)
            
            if let index = self.nearbyPeers.firstIndex(where: {$0.peerID == peerID}) {
                self.nearbyPeers.remove(at: index)
            }
//            print("after lost: ", self.nearbyPeers.map({($0.peerID, $0.peerID.displayName)}))
        }
        
    }
    
}

// MARK: Advertiser
extension MultipeerSession: MCNearbyServiceAdvertiserDelegate {
    
    
    /// - Tag: AcceptInvite
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        //        Open the modal dialog and use the callback
        
//        guard let context = context else { return }
//        
//        let object = try! NSKeyedUnarchiver.unarchivedObject(ofClasses: [Room.self, Player.self, Team.self, Rock.self, MCPeerID.self, NSString.self, ARAnchor.self, SCNNode.self, NSArray.self], from: context)
//        
//        switch object {
//        case let string as NSString:
//            handleInvitationString(text: string, invitationHandler: invitationHandler)
//        case let player as Player:
//            handleInvitationPlayer(peer: peerID, player: player, invitationHandler: invitationHandler)
//        default:
//            print("Unknown type received")
//        }
//        
//        print("invitation masuk")
        
        DispatchQueue.main.async {
            invitationHandler(true, self.session)
//            print("after invite: ", self.session.connectedPeers)
        }
    }
    
    func handleInvitationString(text: NSString,invitationHandler: @escaping (Bool, MCSession?) -> Void){
        if text == "approved"{
            invitationHandler(true,self.session)
        }
    }
    
    func handleInvitationPlayer(peer: MCPeerID, player: Player,invitationHandler: @escaping (Bool, MCSession?) -> Void){
        showInviteModal?(player.profile, peer, { accepted in
            invitationHandler(accepted, self.session)
        })
    }
}

extension MCPeerID: NSSecureCoding {
    public static var supportsSecureCoding: Bool = true
}

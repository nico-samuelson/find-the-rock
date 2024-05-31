//
//  PlayerModel.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 30/05/24.
//

import Foundation
import MultipeerConnectivity

@Observable
class Player {
    static var supportsSecureCoding: Bool = true
    
//    func encode(with coder: NSCoder) {
//        coder.encode(peerID, forKey: "peerID")
//        coder.encode(profile, forKey: "profile")
//        coder.encode(status, forKey: "status")
//        coder.encode(point, forKey: "point")
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        guard let peerID = aDecoder.decodeObject(forKey: "peerID") as? MCPeerID,
//              let profile = aDecoder.decodeObject(forKey: "profile") as? String,
//              let status = aDecoder.decodeObject(forKey: "status") as? PlayerStatus,
//              let point = aDecoder.decodeObject(forKey: "point") as? Int
//        else {
//            return nil
//        }
//        
//        self.peerID = peerID
//        self.profile = profile
//        self.status = status
//        self.point = point
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(profile, forKey: .profile)
//        try container.encode(point, forKey: .point)
//    }
//    
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
////        peerID = try container.decode(String.self, forKey: .peerID)
////        status = try container.decode(PlayerStatus.self, forKey: .status)
//        profile = try container.decode(String.self, forKey: .profile)
//        point = try container.decode(Int.self, forKey: .point)
//        
//        
//    }
    
    var peerID: MCPeerID = MCPeerID(displayName: UIDevice().systemName)
    var profile: String = "default profile"
    var status: PlayerStatus = .disconnected
    var point: Int = 0
    
    init(peerID: MCPeerID, profile: String, status: PlayerStatus, point: Int) {
        self.peerID = peerID
        self.profile = profile
        self.status = status
        self.point = point
    }
    
    private enum CodingKeys: String, CodingKey {
        case peerID, profile, status, point
    }
}

enum PlayerStatus: String {
    case disconnected = "disconnected", connected = "connected"
}

//
//  PlayerModel.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 30/05/24.
//

import Foundation
import MultipeerConnectivity

@Observable
class Player: NSObject, NSCoding, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    var peerID: MCPeerID = MCPeerID(displayName: UIDevice().systemName)
    var profile: String = "default profile"
    var status: PlayerStatus = .disconnected
    var point: Int = 0
    var isPlanter: Bool = false
    
    func encode(with coder: NSCoder) {
        coder.encode(peerID, forKey: "peerID")
        coder.encode(profile, forKey: "profile")
        coder.encode(status.rawValue, forKey: "status")
        coder.encode(point, forKey: "point")
        coder.encode(isPlanter, forKey: "isPlanter")
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let peerID = aDecoder.decodeObject(forKey: "peerID") as? MCPeerID,
              let profile = aDecoder.decodeObject(forKey: "profile") as? String,
              let statusRawValue = aDecoder.decodeObject(forKey: "status") as? String,
              let status = PlayerStatus(rawValue: statusRawValue),
              let point = aDecoder.decodeInteger(forKey: "point") as? Int,
              let isPlanter = aDecoder.decodeBool(forKey: "isPlanter") as? Bool
        else {
            return nil
        }
        
        self.peerID = peerID
        self.profile = profile
        self.status = status
        self.point = point
        self.isPlanter = isPlanter
    }
    
    init(peerID: MCPeerID, profile: String, status: PlayerStatus, point: Int, isPlanter: Bool) {
        self.peerID = peerID
        self.profile = profile
        self.status = status
        self.point = point
        self.isPlanter = isPlanter
    }
    
    private enum CodingKeys: String, CodingKey {
        case peerID, profile, status, point, isPlanter
    }
}

enum PlayerStatus: String {
    case disconnected = "disconnected", connected = "connected"
}

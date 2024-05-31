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
    var peerID: MCPeerID = MCPeerID(displayName: UIDevice().systemName)
    var profile: String = ""
    var status: PlayerStatus = .disconnected
    var point: Int = 0
    
    init() {}
    
    init(peerID: MCPeerID, profile: String, status: PlayerStatus, point: Int) {
        self.peerID = peerID
        self.profile = profile
        self.status = status
        self.point = point
    }
}

enum PlayerStatus {
    case disconnected, connected
}

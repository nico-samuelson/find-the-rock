//
//  TeamModel.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 30/05/24.
//

import Foundation
import MultipeerConnectivity

@Observable
class Team: NSObject, NSCoding, NSSecureCoding {
    var players: [Player] = []
    var fakePlanted: [Rock] = []
    var realPlanted: [Rock] = []
    static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(players, forKey: "players")
        coder.encode(fakePlanted, forKey: "fakePlanted")
        coder.encode(realPlanted, forKey: "realPlanted")
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let players = aDecoder.decodeObject(forKey: "players") as? [Player],
              let fakePlanted = aDecoder.decodeObject(forKey: "fakePlanted") as? [Rock],
              let realPlanted = aDecoder.decodeObject(forKey: "realPlanted") as? [Rock]
        else {
            return nil
        }
        
        self.players = players
        self.fakePlanted = fakePlanted
        self.realPlanted = realPlanted
    }
    
    override init() {}
    
    init(players: [Player], fakePlanted: [Rock], realPlanted: [Rock]) {
        self.players = players
        self.fakePlanted = fakePlanted
        self.realPlanted = realPlanted
    }
    
    private enum CodingKeys: String, CodingKey {
        case players, fakePlanted, realPlanted
    }
}

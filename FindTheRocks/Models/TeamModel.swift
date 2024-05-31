//
//  TeamModel.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 30/05/24.
//

import Foundation

@Observable
class Team {
    var players: [Player] = []
    var fakePlanted: [Rock] = []
    var realPlanted: [Rock] = []
    
    init(){}
    
    init(players: [Player], fakePlanted: [Rock], realPlanted: [Rock]) {
        self.players = players
        self.fakePlanted = fakePlanted
        self.realPlanted = realPlanted
    }
}

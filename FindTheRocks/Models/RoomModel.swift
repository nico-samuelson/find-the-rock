//
//  RoomModel.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 30/05/24.
//

import Foundation

@Observable
class Room {
    var teams: [Team] = [Team(), Team()]
    var hideTime: Int = 0
    var seekTime: Int = 0
    var fakeRock: Int = 0
    var realRock: Int = 0
    
    init() {
        
    }
    
    init(teams: [Team], hideTime: Int, seekTime: Int, fakeRock: Int, realRock: Int) {
        self.teams = teams
        self.hideTime = hideTime
        self.seekTime = seekTime
        self.fakeRock = fakeRock
        self.realRock = realRock
    }
}

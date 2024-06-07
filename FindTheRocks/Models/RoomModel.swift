//
//  RoomModel.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 30/05/24.
//

import Foundation

@Observable
class Room: NSObject, NSCoding, NSSecureCoding {
    var name: String = "Player \(Int.random(in:1...100))"
    var teams: [Team] = [Team(), Team()]
    var hideTime: Int = 2
    var seekTime: Int = 2
    var fakeRock: Int = 3
    var realRock: Int = 3
    static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(teams, forKey: "teams")
        coder.encode(hideTime, forKey: "hideTime")
        coder.encode(seekTime, forKey: "seekTime")
        coder.encode(fakeRock, forKey: "fakeRock")
        coder.encode(realRock, forKey: "realRock")
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: "name") as? String,
              let teams = aDecoder.decodeObject(forKey: "teams") as? [Team],
              let hideTime = aDecoder.decodeInteger(forKey: "hideTime") as? Int,
              let seekTime = aDecoder.decodeInteger(forKey: "seekTime") as? Int,
              let fakeRock = aDecoder.decodeInteger(forKey: "fakeRock") as? Int,
              let realRock = aDecoder.decodeInteger(forKey: "realRock") as? Int
        else {
            return nil
        }
        
        self.name = name
        self.teams = teams
        self.hideTime = hideTime
        self.seekTime = seekTime
        self.fakeRock = fakeRock
        self.realRock = realRock
    }
    
    init(name: String, teams: [Team], hideTime: Int, seekTime: Int, fakeRock: Int, realRock: Int) {
        self.name = name
        self.teams = teams
        self.hideTime = hideTime
        self.seekTime = seekTime
        self.fakeRock = fakeRock
        self.realRock = realRock
    }
    
    init(name: String) {
        self.name = name
    }
    
    override init() {}
    
    private enum CodingKeys: String, CodingKey {
        case name, teams, hideTime, seekTime, fakeRock, realRock
    }
    
    func getAllPlantedRocks() -> [Rock] {
        return teams[0].fakePlanted + teams[0].realPlanted + teams[1].fakePlanted + teams[1].realPlanted
    }
    
    func getTeamRocks(team: Int) -> [Rock] {
        return teams[team].fakePlanted + teams[team].realPlanted
    }
}

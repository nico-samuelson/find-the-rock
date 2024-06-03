//
//  RoomModel.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 30/05/24.
//

import Foundation

@Observable
class Room: NSObject, NSCoding, NSSecureCoding {
    var teams: [Team] = [Team(), Team()]
    var hideTime: Int = 0
    var seekTime: Int = 0
    var fakeRock: Int = 0
    var realRock: Int = 0
    static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(teams, forKey: "teams")
        coder.encode(hideTime, forKey: "hideTime")
        coder.encode(seekTime, forKey: "seekTime")
        coder.encode(fakeRock, forKey: "fakeRock")
        coder.encode(realRock, forKey: "realRock")
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let teams = aDecoder.decodeObject(forKey: "teams") as? [Team],
              let hideTime = aDecoder.decodeInteger(forKey: "hideTime") as? Int,
              let seekTime = aDecoder.decodeInteger(forKey: "seekTime") as? Int,
              let fakeRock = aDecoder.decodeInteger(forKey: "fakeRock") as? Int,
              let realRock = aDecoder.decodeInteger(forKey: "realRock") as? Int
        else {
            return nil
        }
        
        self.teams = teams
        self.hideTime = hideTime
        self.seekTime = seekTime
        self.fakeRock = fakeRock
        self.realRock = realRock
    }
    
    init(teams: [Team], hideTime: Int, seekTime: Int, fakeRock: Int, realRock: Int) {
        self.teams = teams
        self.hideTime = hideTime
        self.seekTime = seekTime
        self.fakeRock = fakeRock
        self.realRock = realRock
    }
    
    override init() {}
    
    private enum CodingKeys: String, CodingKey {
        case teams, hideTime, seekTime, fakeRock, realRock
    }
}

import Foundation
import ARKit

class ARData: NSObject, NSCoding, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    let room: Room
    let map: ARWorldMap

    init(room: Room, map: ARWorldMap) {
        self.room = room
        self.map = map
    }

    required init?(coder aDecoder: NSCoder) {
        guard let room = aDecoder.decodeObject(forKey: "room") as? Room,
              let map = aDecoder.decodeObject(forKey: "map") as? ARWorldMap
        else { return nil }
        
        self.room = room
        self.map = map
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(room, forKey: "room")
        aCoder.encode(map, forKey: "map")
    }
    
    private enum CodingKeys: String, CodingKey {
        case room, map
    }
}

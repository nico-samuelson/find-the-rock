import Foundation
import ARKit

class CustomAnchor: NSObject, NSCoding, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    let anchor: ARAnchor
    let action: String
    let isReal: Bool

    init(anchor: ARAnchor, action: String, isReal: Bool) {
        self.anchor = anchor
        self.action = action
        self.isReal = isReal
    }

    required init?(coder aDecoder: NSCoder) {
        guard let anchor = aDecoder.decodeObject(forKey: "anchor") as? ARAnchor,
              let action = aDecoder.decodeObject(forKey: "action") as? String,
              let isReal = aDecoder.decodeBool(forKey: "isReal") as? Bool
        else { return nil }
        
        self.anchor = anchor
        self.action = action
        self.isReal = isReal
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(anchor, forKey: "anchor")
        aCoder.encode(action, forKey: "action")
        aCoder.encode(isReal, forKey: "isReal")
    }
    
    private enum CodingKeys: String, CodingKey {
        case anchor, action, isReal
    }
}

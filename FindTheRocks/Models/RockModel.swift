//
//  RockModel.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 30/05/24.
//

import Foundation
import ARKit

@Observable
class Rock: NSObject, NSCoding, NSSecureCoding {
    var id: UUID = UUID.init()
    var isFake: Bool = false
    var anchor: ARAnchor = ARAnchor(name: "", transform: simd_float4x4())
    static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(isFake, forKey: "isFake")
        coder.encode(anchor, forKey: "anchor")
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let isFake = aDecoder.decodeBool(forKey: "isFake") as? Bool,
              let anchor = aDecoder.decodeObject(forKey: "anchor") as? ARAnchor
        else {
            return nil
        }
        
        self.isFake = isFake
        self.anchor = anchor
    }
    
    init(isFake: Bool, anchor: ARAnchor) {
        self.isFake = isFake
        self.anchor = anchor
    }
    
    private enum CodingKeys: String, CodingKey {
        case isFake, anchor
    }
}

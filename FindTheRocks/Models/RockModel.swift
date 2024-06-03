//
//  RockModel.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 30/05/24.
//

import Foundation
import SceneKit
import ARKit

@Observable
class Rock: NSObject, NSCoding, NSSecureCoding {
    var isFake: Bool = false
    var anchor: ARAnchor = ARAnchor(name: "", transform: simd_float4x4())
    var node: SCNNode = SCNNode()
    static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(isFake, forKey: "isFake")
        coder.encode(anchor, forKey: "anchor")
        coder.encode(node, forKey: "node")
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let isFake = aDecoder.decodeBool(forKey: "isFake") as? Bool,
              let anchor = aDecoder.decodeObject(forKey: "anchor") as? ARAnchor,
              let node = aDecoder.decodeObject(forKey: "node") as? SCNNode
        else {
            return nil
        }
        
        self.isFake = isFake
        self.anchor = anchor
        self.node = node
    }
    
    init(isFake: Bool, anchor: ARAnchor, node: SCNNode) {
        self.isFake = isFake
        self.anchor = anchor
        self.node = node
    }
    
    private enum CodingKeys: String, CodingKey {
        case isFake, anchor, node
    }
}

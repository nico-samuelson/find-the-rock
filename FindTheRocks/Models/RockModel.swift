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
class Rock {
    var isFake: Bool = false
    var anchor: ARAnchor = ARAnchor(name: "", transform: simd_float4x4())
    var node: SCNNode = SCNNode()
    
    init() {}
    
    init(isFake: Bool, anchor: ARAnchor, node: SCNNode) {
        self.isFake = isFake
        self.anchor = anchor
        self.node = node
    }
}

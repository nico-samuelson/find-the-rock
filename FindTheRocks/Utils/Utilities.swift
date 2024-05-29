/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Convenience extensions on system types.
*/

import simd
import ARKit
import MultipeerConnectivity

extension ARFrame.WorldMappingStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notAvailable:
            return "Not Available"
        case .limited:
            return "Limited"
        case .extending:
            return "Extending"
        case .mapped:
            return "Mapped"
        @unknown default:
            return "Unknown"
        }
    }
}
func receivedData(_ data: Data, from peer: MCPeerID) {
    
    do {
//        if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
//            // Run the session with the received world map.
//            let configuration = ARWorldTrackingConfiguration()
//            configuration.planeDetection = [.horizontal, .vertical]
//            configuration.initialWorldMap = worldMap
//            sceneView.session.run(configuration, options: [.resetTracking])
//            
//            // Remember who provided the map for showing UI feedback.
//            mapProvider = peer
//        }
//        else
//        if let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) {
//            // Add anchor to the session, ARSCNView delegate adds visible content.
//            //                sceneView.session.add(anchor: anchor)
//            // Get current device transform (position and orientation)
//            guard let currentFrame = sceneView.session.currentFrame else {
//                print("Couldn't get current frame")
//                return
//            }
//            let currentTransform = currentFrame.camera.transform
//            
//            // Extract the translation and rotation components of the current transform
//            let currentTranslation = currentTransform.columns.3
//            let currentRotation = simd_quatf(currentTransform)
//            
//            // Extract the translation and rotation components of the received anchor's transform
//            let anchorTranslation = anchor.transform.columns.3
//            let anchorRotation = simd_quatf(anchor.transform)
//            
//            // Calculate the new position: your current position + the relative position of the anchor
//            let newTranslation = currentTranslation + anchorTranslation
//            
//            // Combine the rotations: your current rotation * anchor's rotation
//            let newRotation = currentRotation * anchorRotation
//            
//            // Construct the new transform with the combined translation and rotation
//            var newTransform = matrix_identity_float4x4
//            newTransform.columns.3 = newTranslation
//            newTransform = matrix_float4x4(newRotation)
//            newTransform.columns.3 = newTranslation
//            
//            // Create a new anchor with the transformed position and orientation
//            let newAnchor = ARAnchor(name: anchor.name!, transform: newTransform)
//            
//            // Add the transformed anchor to the session
//            sceneView.session.add(anchor: newAnchor)
//        }
//        else {
//            print("unknown data recieved from \(peer)")
//        }
    } catch {
        print("can't decode data recieved from \(peer)")
    }
}

//
//  MultipeerSceneView.swift
//  FindTheRocks
//
//  Created by Nico Samuelson on 03/06/24.
//

import Foundation
import ARKit

extension MultipeerSession: ARSCNViewDelegate, ARSessionDelegate {
    
    // MARK: Renderer
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //        print("render ulang")
        guard let frame = sceneView.session.currentFrame else { return }
        guard let cameraPosition = cameraPosition else { return }
        guard let cameraTransform = cameraTransform else { return }
        
        self.cameraTransform = SCNMatrix4(frame.camera.transform)
        self.cameraPosition = SCNVector3(cameraTransform.m41, cameraTransform.m42, cameraTransform.m43)
        
        if let name = anchor.name, name.contains("rock") {
            print(sceneView.scene.rootNode.childNodes.count)
            // load rock model
            let pandaNode = name.hasPrefix("fake") ? loadRockModel(false): loadRockModel(true)
            pandaNode.renderingOrder = 0
            pandaNode.name = anchor.identifier.uuidString
            node.addChildNode(pandaNode)
            sceneView.scene.rootNode.addChildNode(node)
            
            // create new rock model
            let rock = Rock(isFake: self.isPlantingFakeRock, anchor: anchor)
        }
    }
    
    // MARK: 3D Vector Distance
    func SCNVector3Distance(vectorStart: SCNVector3, vectorEnd: SCNVector3) -> Float {
        let dx = vectorStart.x - vectorEnd.x
        let dy = vectorStart.y - vectorEnd.y
        let dz = vectorStart.z - vectorEnd.z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }
    
    // MARK: Plane Node
    private func createPlaneNode(with planeAnchor: ARPlaneAnchor) -> SCNNode {
        //        let wallHeight: CGFloat = 10.0 // Adjust this value based on your needs
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        plane.materials.first?.diffuse.contents = UIColor.red.withAlphaComponent(0.5)
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.eulerAngles.x = -.pi / 2
        planeNode.name = "Cok sidi"
        
        return planeNode
    }
    
    // MARK: - ARSessionDelegate
    //    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    //        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    //        showVirtualContent()
    //    }
    
    /// - Tag: CheckMappingStatus
    // MARK: Session Update
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let cameraPosition = self.cameraPosition else { return }
        guard let cameraTransform = self.cameraTransform else { return }
        
        updateRock()
        //        switch frame.worldMappingStatus {
        //        case .notAvailable, .limited:
        //            sessionShareWorldButton.isEnabled = false
        //            sessionShareWorldButton.backgroundColor = .systemGray
        //        case .extending:
        //            let isEnabled = !multipeerSession.connectedPeers.isEmpty
        //            sessionShareWorldButton.isEnabled = isEnabled
        //            sessionShareWorldButton.backgroundColor = isEnabled ? .systemBlue : .systemGray
        //        case .mapped:
        //            let isEnabled = !multipeerSession.connectedPeers.isEmpty
        //            sessionShareWorldButton.isEnabled = isEnabled
        //            sessionShareWorldButton.backgroundColor = isEnabled ? .systemBlue : .systemGray
        //        @unknown default:
        //            sessionShareWorldButton.isEnabled = false
        //            sessionShareWorldButton.backgroundColor = .systemGray
        //        }
        self.cameraTransform = SCNMatrix4(frame.camera.transform)
        self.cameraPosition = SCNVector3Make(cameraTransform.m41, cameraTransform.m42, cameraTransform.m43)
        self.mappingStatusLabel.text = frame.worldMappingStatus.description
    }
    
    //    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    //
    //    }
    //
    //    func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
    ////        guard let multipeerSession = self.multipeerSession else { return }
    ////        print("output collaboration data")
    //        if !self.connectedPeers.isEmpty {
    //            guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
    //            else { fatalError("Unexpectedly failed to encode collaboration data.") }
    //            // Use reliable mode if the data is critical, and unreliable mode if the data is optional.
    //            let dataIsCritical = data.priority == .critical
    //
    ////            var tries = 0
    ////            var timer: Timer?
    ////            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
    //            self.sendToAllPeers(encodedData)
    ////                tries += 1
    ////                if (tries >= 5) {
    ////                    timer?.invalidate()
    ////                }
    ////            }
    //        } else {
    //            print("Deferred sending collaboration to later because there are no peers.")
    //        }
    //    }
    
    // MARK: Update Rock Visibility
    func updateRock() {
        guard let cameraPosition = self.cameraPosition else { return }
        
        let myTeam = self.getTeam(self.peerID)
        let visibleTeamRock = isPlanting ? myTeam : (myTeam == 1 ? 0 : 1)
        let visibleRocks = self.room.getTeamRocks(team: visibleTeamRock)
        let hiddenRocks = self.room.getTeamRocks(team: visibleTeamRock == 0 ? 1 : 0)
        
        for rock in visibleRocks {
            let anchorScreenPosition = getAnchorPositionInScreen(anchor: rock.anchor)
            
            let hitTestOptions: [SCNHitTestOption: Any] = [.firstFoundOnly: true, .ignoreHiddenNodes: false]
            let hitTestResult = self.sceneView.hitTest(anchorScreenPosition, options: hitTestOptions)
            
            if (!self.isPlanting) {
                let distance = SCNVector3Distance(vectorStart: cameraPosition, vectorEnd: SCNVector3(x: rock.anchor.transform.columns.3.x, y: rock.anchor.transform.columns.3.y, z: rock.anchor.transform.columns.3.z))
                
                guard let longPressedNode = hitTestResult.map({ $0.node }).first
                else { return }
                
                if distance > 1.5 {
                    longPressedNode.parent?.parent?.isHidden = true
                }
                else {
                    longPressedNode.parent?.parent?.isHidden = false
                }
            }
        }
        
        for rock in hiddenRocks {
            let anchorScreenPosition = getAnchorPositionInScreen(anchor: rock.anchor)
            
            let hitTestOptions: [SCNHitTestOption: Any] = [.firstFoundOnly: true]
            let hitTestResult = self.sceneView.hitTest(anchorScreenPosition, options: hitTestOptions)
            
            if let longPressedNode = hitTestResult.map({ $0.node }).first {
                longPressedNode.parent?.parent?.isHidden = true
            }
        }
    }
    
    func getAnchorPositionInScreen(anchor: ARAnchor) -> CGPoint {
        let anchorTransform = anchor.transform
        let anchorPosition = SCNVector3(anchorTransform.columns.3.x, anchorTransform.columns.3.y, anchorTransform.columns.3.z)
        
        let projectedPoint = sceneView.projectPoint(anchorPosition)
        let anchorScreenPosition = CGPoint(x: CGFloat(projectedPoint.x), y: CGFloat(projectedPoint.y))
        
        return anchorScreenPosition
    }
    
    // MARK: - AR session management
    private func loadRockModel(_ isReal: Bool) -> SCNNode {
        let sceneURL = isReal ? Bundle.main.url(forResource: "rock-1", withExtension: "scn", subdirectory: "art.scnassets/models")! : Bundle.main.url(forResource: "rock-2", withExtension: "scn", subdirectory: "art.scnassets/models")!
        //        sceneURL
        let referenceNode = SCNReferenceNode(url: sceneURL)!
        
        referenceNode.name = "Rock SCNNode"
        // adjust scale
        let scale: Float = 0.05
        referenceNode.scale = SCNVector3(x: scale, y: scale, z: scale)
        
        referenceNode.load()
        
        
        return referenceNode
    }
    
    // MARK: - ARSessionObserver
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        //        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        //        sessionInfoLabel.text = "Session interruption ended"
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        //        switch camera.trackingState {
        //                case .normal:
        //                    // Tracking is normal
        //                    print("Tracking state is normal.")
        //                case .notAvailable:
        //                    // Tracking is not available
        //                    print("Tracking is not available.")
        //                case .limited(let reason):
        //                    // Tracking is limited, with a reason
        //                    switch reason {
        //                    case .initializing:
        //                        print("Tracking is initializing.")
        //                    case .excessiveMotion:
        //                        print("Tracking limited due to excessive motion.")
        //                    case .insufficientFeatures:
        //                        print("Tracking limited due to insufficient features.")
        //                    case .relocalizing:
        //                        print("Tracking limited due to relocalization.")
        //                    @unknown default:
        //                        print("Unknown tracking state.")
        //                    }
        //                }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        //        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        //        return errorMessage
        
        //        DispatchQueue.main.async {
        //            // Present an alert informing about the error that has occurred.
        //            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
        //            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
        //                alertController.dismiss(animated: true, completion: nil)
        //                self.resetTracking(nil)
        //            }
        //            alertController.addAction(restartAction)
        //            self.present(alertController, animated: true, completion: nil)
        //        }
    }
}

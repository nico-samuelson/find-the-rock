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
            
            let allRocks = self.room.getAllPlantedRocks()
            
            for rock in allRocks {
                if (rock.anchor.name == anchor.name) {
                    rock.anchor = anchor
                }
            }
            
            // create new rock model
//            let rock = Rock(isFake: self.isPlantingFakeRock, anchor: anchor)
        }
    }
    
    // MARK: 3D Vector Distance
    func SCNVector3Distance(vectorStart: SCNVector3, vectorEnd: SCNVector3) -> Float {
        let dx = vectorStart.x - vectorEnd.x
        let dy = vectorStart.y - vectorEnd.y
        let dz = vectorStart.z - vectorEnd.z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }
    
    /// - Tag: CheckMappingStatus
    // MARK: Session Update
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let cameraPosition = self.cameraPosition else { return }
        guard let cameraTransform = self.cameraTransform else { return }
        
        updateRock()
        
        self.cameraTransform = SCNMatrix4(frame.camera.transform)
        self.cameraPosition = SCNVector3Make(cameraTransform.m41, cameraTransform.m42, cameraTransform.m43)
        self.mappingStatusLabel.text = frame.worldMappingStatus.description
    }
    
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
        let scale: Float = 0.1
        referenceNode.scale = SCNVector3(x: scale, y: scale, z: scale)
        
        referenceNode.load()
        
        return referenceNode
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
    }
}

//
//  HomeViewController.swift
//  MultiplayerARGame
//
//  Created by Nico Samuelson on 21/05/24.
//

import UIKit
import SwiftUI
import ARKit
import SceneKit
import MultipeerConnectivity
import Vision

class ARController: UIViewController {
    var multipeerSession: MultipeerSession
    var detectionRadius: CGFloat = 0.5 // Default radius in meters
    var mapProvider: MCPeerID? = MCPeerID(displayName: UIDevice().name)
    
    init(multipeerSession: MultipeerSession) {
        self.multipeerSession = multipeerSession
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print("ARController Running...")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSceneTap))
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))

        self.view.addGestureRecognizer(tapGesture)
        self.view.addGestureRecognizer(longPressGesture)
        setup()
    
        multipeerSession.sceneView.session.delegate = multipeerSession
        multipeerSession.sceneView.delegate = multipeerSession
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
//        configuration.isCollaborationEnabled = true
        configuration.environmentTexturing = .automatic
//        configuration.worldAlignment = .gravityAndHeading
        multipeerSession.sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        multipeerSession.sceneView.session.pause()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }
        
        // Start the view's AR session.
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        multipeerSession.sceneView.session.run(configuration)
        
        // Set a delegate to track the number of plane anchors for providing UI feedback.
        multipeerSession.sceneView.session.delegate = multipeerSession
        
//        multipeerSession.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        if let objectAtAnchor = self.virtualObjectLoader.loadedObjects.first(where: { $0.anchor == anchor }) {
//            objectAtAnchor.simdPosition = anchor.transform.translation
//            objectAtAnchor.anchor = anchor
//        }
//    }
    
//    @objc func shareSession() {
//        print("masuk gan")
//        multipeerSession.sceneView.session.getCurrentWorldMap { worldMap, error in
//            guard let map = worldMap
//            else { print("Error: \(error!.localizedDescription)"); return }
//            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
//            else { fatalError("can't encode map") }
//            self.multipeerSession.sendToAllPeers(data) { success in
//
//            }
//        }
//    }
    
    // MARK: - AR session management
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty && multipeerSession.connectedPeers.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move around to map the environment, or wait to join a shared session."
            
        case .normal where !multipeerSession.connectedPeers.isEmpty && mapProvider == nil:
            let peerNames = multipeerSession.connectedPeers.map({ $0.displayName }).joined(separator: ", ")
            message = "Connected with \(peerNames)."
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing) where mapProvider != nil,
                .limited(.relocalizing) where mapProvider != nil:
            message = "Received map from \(mapProvider!.displayName)."
            
        case .limited(.relocalizing):
            message = "Resuming session — move to where you were when the session was interrupted."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""
        }
    }
    
//    @IBAction func resetTracking(_ sender: UIButton?) {
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = [.horizontal, .vertical]
//        sceneView.session.run(configuration, options: [.resetTracking])
//    }

//    func findClosestNode(to point: simd_float3) -> SCNNode? {
//        var closestNode: SCNNode?
//        var minimumDistance: Float = .greatestFiniteMagnitude
//
//        for rock in team {
//            let nodePosition = node.simdWorldPosition
//            let distance = simd_distance(nodePosition, point)
//
//            if distance < minimumDistance {
//                minimumDistance = distance
//                closestNode = node
//            }
//        }
//
//        return closestNode
//    }
    
    @objc func handleSceneTap(_ sender: UITapGestureRecognizer) {
        
//        print("Tap Detected")
        // Hit test to find a place for a virtual object.
        guard let hitTestResult = multipeerSession.sceneView
            .hitTest(sender.location(in: multipeerSession.sceneView), types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
            .first
        else { return }
        
        // Place an anchor for a virtual character. The model appears in renderer(_:didAdd:for:).
//        print("tap"
        let anchor = ARAnchor(name: "rockARAnchor", transform: hitTestResult.worldTransform)
        let newAnchor = CustomAnchor(anchor: anchor, action: "add", isReal: !self.multipeerSession.isPlantingFakeRock)
//        multipeerSession.sceneView.session.add(anchor: anchor)
        
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: newAnchor, requiringSecureCoding: true)
        else { print("babi"); return }
        
        print("taptap")
        
        if self.multipeerSession.isMaster {
            self.multipeerSession.handleAnchorChange(anchor, "add", !self.multipeerSession.isPlantingFakeRock, self.multipeerSession.peerID)
        }
        else {
            self.multipeerSession.sendToAllPeers(data)
        }
        
        
        
//        self.sendAnchor(anchor: anchor, mode: "add", timer: <#T##Timer?#>)
//        print(multipeerSession.sceneView.session.currentFrame?.anchors[0])
//        ARWorldTrackingConfiguration.
//         Send the anchor info to peers, so they can place the same content.
        
//        print("taptap")
        
        // send anchor data to all peers
//        var tries = 0
//        var timer: Timer?
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//                self.sendAnchor(anchor, timer: timer)
//                tries += 1
//                if (tries >= 5) {
//                    timer?.invalidate()
//                }
//            }
//        }
    }
    
    @objc func handleLongPress(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended { 
            let touchLocation = gesture.location(in: multipeerSession.sceneView)
            
            let hitTestOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly: true]
            let hitTestResults = multipeerSession.sceneView.hitTest(touchLocation, options: hitTestOptions)
            
            if let longPressedNode = hitTestResults.lazy.compactMap{ result in return result.node}.first {
                
                
                longPressedNode.removeFromParentNode()
                print("\(longPressedNode) berhasil ditekan")

            } else  {
                print("tidak ditemukan object yang tertekan")
            }
        }
    }
    
    func sendAnchor(_ anchor: ARAnchor, mode: String) {
        DispatchQueue.global().async {
            // only send data when there's no world update
            if (!self.multipeerSession.isUpdatingWorldMap) {
                self.multipeerSession.isUpdatingWorldMap = true
                
                print("anchor to be send: ", anchor.transform)
                
                // send room data
//                self.multipeerSession.sendToAllPeers(data: )
                
                guard let anchor = try? NSKeyedArchiver.archivedData(withRootObject: (anchor, mode), requiringSecureCoding: true)
                else { return }
                
                self.multipeerSession.sendToAllPeers(anchor)
                
                        
//                guard let room = try? NSKeyedArchiver.archivedData(withRootObject: self.multipeerSession.room, requiringSecureCoding: true)
//                else { fatalError("can't encode room") }
                
//                self.multipeerSession.sendARData(room) { success in
//                    print("success sending room: ", success)
//                    // invalidate timer when room is failed to sent
//                    if (!success) { timer?.invalidate() }
//                    
//                    // send AR world map data
//                    else {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                            self.multipeerSession.sceneView.session.getCurrentWorldMap { worldMap, error in
//                                guard let map = worldMap
//                                else { print("Error: \(error!)"); return }
//                                guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
//                                else { fatalError("can't encode map") }
//                                self.multipeerSession.sendARData(data) { success in
//                                    print("success sending world map: ", success)
//                                    if (success) { timer?.invalidate() }
//                                }
//                                self.multipeerSession.isUpdatingWorldMap = false
//                            }
//                        }
//                    }
//                }
            }
        }
    }

    // Helper function to calculate the distance between two points
    func distanceBetweenPoints(pointA: SCNVector3, pointB: SCNVector3) -> CGFloat {
        let vector = SCNVector3Make(pointA.x - pointB.x, pointA.y - pointB.y, pointA.z - pointB.z)
        return CGFloat(sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z))
    }
}

private extension ARController {
    func setup() {
        self.view.addSubview(multipeerSession.sceneView)
        self.view.addSubview(multipeerSession.mappingStatusLabel)
        
        NSLayoutConstraint.activate([
            multipeerSession.sceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
            multipeerSession.sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            multipeerSession.sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            multipeerSession.sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            multipeerSession.mappingStatusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 20),
            multipeerSession.mappingStatusLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])
    }
}

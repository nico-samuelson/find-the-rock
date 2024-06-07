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
    var counter = 1
    
    init(multipeerSession: MultipeerSession) {
        self.multipeerSession = multipeerSession
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print("ARController Running...")
        
        print("loaded nodes: ", multipeerSession.sceneView.scene.rootNode.childNodes.map { $0.hashValue })
        
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
        configuration.worldAlignment = .gravityAndHeading
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
        multipeerSession.sceneView.session.delegate = multipeerSession
        
        //        multipeerSession.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
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
    
    @objc func handleSceneTap(_ sender: UITapGestureRecognizer) {
        if multipeerSession.isPlanting {
            // Hit test to find a place for a virtual object.
            guard let hitTestResult = multipeerSession.sceneView
                .hitTest(sender.location(in: multipeerSession.sceneView), types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
                .first
            else { return }
            
            // Place an anchor for a virtual character. The model appears in renderer(_:didAdd:for:).
            let anchor = multipeerSession.isPlantingFakeRock ? ARAnchor(name: "fakerockARAnchor-\(counter)", transform: hitTestResult.worldTransform) : ARAnchor(name: "rockARAnchor-\(counter)", transform: hitTestResult.worldTransform)
            counter += 1
            let newAnchor = CustomAnchor(anchor: anchor, action: "add", isReal: !self.multipeerSession.isPlantingFakeRock)
            
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: newAnchor, requiringSecureCoding: true)
            else { print("babi"); return }
            
            print("taptap")
            print("anchir: ",anchor.identifier)
            
            //            if self.multipeerSession.isMaster {
            self.multipeerSession.handleAnchorChange(anchor, "add", !self.multipeerSession.isPlantingFakeRock, self.multipeerSession.peerID)
            //            }
            //            else {
            //                self.multipeerSession.sendToAllPeers(data)
            //            }
        }
    }
    
    @objc func handleLongPress(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            let touchLocation = gesture.location(in: multipeerSession.sceneView)
            
            let hitTestOptions: [SCNHitTestOption: Any] = [.firstFoundOnly: true]
            let hitTestResults = multipeerSession.sceneView.hitTest(touchLocation, options: hitTestOptions)
            
            //            hitTestRes
            // get clicked node
            if let longPressedNode = hitTestResults.map { $0.node }.first {
                longPressedNode.parent?.parent?.removeFromParentNode()
                
                for rock in multipeerSession.room.getAllPlantedRocks() {
                    if rock.anchor.identifier == UUID(uuidString: longPressedNode.parent?.name ?? "") {
                        print(self.multipeerSession.isPlantingFakeRock)
                        print(rock.isFake)
                        print("anchor found")
                        guard let anchor = try? NSKeyedArchiver.archivedData(withRootObject: CustomAnchor(anchor: rock.anchor, action: "remove", isReal: !rock.isFake), requiringSecureCoding: true)
                        else { return }
                        
                        if self.multipeerSession.isPlanting {
                            self.multipeerSession.handleAnchorChange(rock.anchor, "remove", !rock.isFake, self.multipeerSession.peerID)
                        }
                        else {
                            self.multipeerSession.handleAnchorChange(rock.anchor, "pick", !rock.isFake, self.multipeerSession.peerID)
                        }
                        
                        
                    }
                }
            } else  {
                print("tidak ditemukan object yang tertekan")
            }
            print("root node names: ", multipeerSession.sceneView.scene.rootNode.childNodes.map { $0.childNodes.map { $0.name } })
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

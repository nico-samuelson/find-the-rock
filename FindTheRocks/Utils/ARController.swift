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

class ARController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    var cameraTransform: SCNMatrix4? = SCNMatrix4()
    var cameraPosition: SCNVector3? = SCNVector3(x: 0, y: 0, z: 0)
    var addedNodes = [ARAnchor : SCNNode]()
    var multipeerSession: MultipeerSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSceneTap))
        
        self.view.addGestureRecognizer(tapGesture)
        
        setup()
        
        sceneView.session.delegate = self
        sceneView.delegate = self
        
        multipeerSession = MultipeerSession(receivedDataHandler: receivedData)
    }
    
    private lazy var sessionInfoView: UIView = {
        let blurEffect = UIBlurEffect(style: .light)
        let sv = UIVisualEffectView(effect: blurEffect)
        
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.layer.cornerRadius = 100
        
        return sv
    }()
   
    private lazy var sessionInfoLabel: UILabel = {
        let sl = UILabel()
        sl.translatesAutoresizingMaskIntoConstraints = false
        sl.lineBreakMode = .byWordWrapping
        sl.numberOfLines = 0
        sl.preferredMaxLayoutWidth = 200
        sl.text = "Testing"
        sl.textColor = .white
        
        return sl
    }()

    private var sessionShareWorldButton: UIButton = {
        let swb = UIButton()
        swb.translatesAutoresizingMaskIntoConstraints = false
        swb.setTitle("Share World", for: .normal)
        swb.titleEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        swb.backgroundColor = swb.isEnabled ? .systemBlue : .systemGray
        swb.layer.cornerRadius = 25
        swb.addTarget(self, action: #selector(shareSession), for: .touchDown)
        
        return swb
    }()
    
    var sceneView: ARSCNView! = {
        let sceneView = ARSCNView()
        
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        return sceneView
    }()
    
    var mappingStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Mapping"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
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
        sceneView.session.run(configuration)
        
        // Set a delegate to track the number of plane anchors for providing UI feedback.
        sceneView.session.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("new anchor")
        guard let frame = sceneView.session.currentFrame else { return }
        guard let cameraPosition = cameraPosition else { return }
        guard let cameraTransform = cameraTransform else { return }
        self.cameraTransform = SCNMatrix4(frame.camera.transform)
        self.cameraPosition = SCNVector3(cameraTransform.m41, cameraTransform.m42, cameraTransform.m43)
        
        if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical || planeAnchor.alignment == .horizontal {
            let planeNode = createPlaneNode(with: planeAnchor)
            planeNode.renderingOrder = -1
            node.addChildNode(planeNode)
        }
        
        print("print camera \(self.cameraPosition)")
        
        if let name = anchor.name, name.hasPrefix("panda") {
            let pandaNode = loadRedPandaModel()
            pandaNode.renderingOrder = 0
            pandaNode.name = "panda"
            print(pandaNode.name)
            node.addChildNode(pandaNode)
            addedNodes[anchor] = pandaNode
            let pandaTransform = SCNVector3(x: anchor.transform.columns.3.x, y: anchor.transform.columns.3.y, z: anchor.transform.columns.3.z)
            let distance = SCNVector3Distance(vectorStart: cameraPosition, vectorEnd: pandaTransform)
            pandaNode.isHidden = distance > 1
        }
        
        print("\(node.childNodes.map { $0.name })")
    }
    
    func SCNVector3Distance(vectorStart: SCNVector3, vectorEnd: SCNVector3) -> Float {
        let dx = vectorStart.x - vectorEnd.x
        let dy = vectorStart.y - vectorEnd.y
        let dz = vectorStart.z - vectorEnd.z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }
    
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
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    /// - Tag: CheckMappingStatus
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let cameraPosition = self.cameraPosition else { return }
        guard let cameraTransform = self.cameraTransform else { return }
        
        updatePanda()
        switch frame.worldMappingStatus {
        case .notAvailable, .limited:
            sessionShareWorldButton.isEnabled = false
            sessionShareWorldButton.backgroundColor = .systemGray
        case .extending:
            let isEnabled = !multipeerSession.connectedPeers.isEmpty
            sessionShareWorldButton.isEnabled = isEnabled
            sessionShareWorldButton.backgroundColor = isEnabled ? .systemBlue : .systemGray
        case .mapped:
            let isEnabled = !multipeerSession.connectedPeers.isEmpty
            sessionShareWorldButton.isEnabled = isEnabled
            sessionShareWorldButton.backgroundColor = isEnabled ? .systemBlue : .systemGray
        @unknown default:
            sessionShareWorldButton.isEnabled = false
            sessionShareWorldButton.backgroundColor = .systemGray
        }
        self.cameraTransform = SCNMatrix4(frame.camera.transform)
        self.cameraPosition = SCNVector3Make(cameraTransform.m41, cameraTransform.m42, cameraTransform.m43)
        mappingStatusLabel.text = frame.worldMappingStatus.description
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func updatePanda() {
        guard let cameraPosition = self.cameraPosition else { return }
        for (anchor, node) in addedNodes {
            let distance = SCNVector3Distance(vectorStart: cameraPosition, vectorEnd: SCNVector3(x: anchor.transform.columns.3.x, y: anchor.transform.columns.3.y, z: anchor.transform.columns.3.z))
            node.isHidden = distance > 1
        }
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
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
        
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.resetTracking(nil)
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func shareSession() {
        print("masuk gan")
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
            else { print("Error: \(error!.localizedDescription)"); return }
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
            else { fatalError("can't encode map") }
            self.multipeerSession.sendToAllPeers(data)
        }
    }
    
    var mapProvider: MCPeerID?
    
    /// - Tag: ReceiveData
    
    
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
        
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }
    
    @IBAction func resetTracking(_ sender: UIButton?) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - AR session management
    private func loadRedPandaModel() -> SCNNode {
        let sceneURL = Bundle.main.url(forResource: "max", withExtension: "scn", subdirectory: "art.scnassets")!
        let referenceNode = SCNReferenceNode(url: sceneURL)!
        referenceNode.load()
        
        return referenceNode
    }
    
    @objc func handleSceneTap(_ sender: UITapGestureRecognizer) {
        print("taptap")
        // Hit test to find a place for a virtual object.
        guard let hitTestResult = sceneView
            .hitTest(sender.location(in: sceneView), types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
            .first
        else { return }
        
        // Place an anchor for a virtual character. The model appears in renderer(_:didAdd:for:).
        let anchor = ARAnchor(name: "panda", transform: hitTestResult.worldTransform)
        sceneView.session.add(anchor: anchor)
        
        // Send the anchor info to peers, so they can place the same content.
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
        else { fatalError("can't encode anchor") }
        //        self.multipeerSession.sendToAllPeers(data)
    }
}

private extension ARController {
    func setup() {
        self.view.addSubview(sceneView)
        self.view.addSubview(sessionInfoView)
        self.view.addSubview(sessionInfoLabel)
        self.view.addSubview(mappingStatusLabel)
        self.view.addSubview(sessionShareWorldButton)
        
        NSLayoutConstraint.activate([
            sessionInfoLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            sessionInfoLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 22),
            sessionInfoView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            sessionInfoView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
        
            sessionInfoView.topAnchor.constraint(equalTo: sessionInfoLabel.topAnchor, constant: -8),
            sessionInfoView.bottomAnchor.constraint(equalTo: sessionInfoLabel.bottomAnchor, constant: 8),
            sessionInfoView.leadingAnchor.constraint(equalTo: sessionInfoLabel.leadingAnchor, constant: -8),
            sessionInfoView.trailingAnchor.constraint(equalTo: sessionInfoLabel.trailingAnchor, constant: 8),
            
            sceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            sessionShareWorldButton.widthAnchor.constraint(equalToConstant: 150),
            sessionShareWorldButton.heightAnchor.constraint(equalToConstant: 50),
            sessionShareWorldButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            sessionShareWorldButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            
            mappingStatusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 20),
            mappingStatusLabel.bottomAnchor.constraint(equalTo: sessionShareWorldButton.topAnchor, constant: -20),
            mappingStatusLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])
    }
}

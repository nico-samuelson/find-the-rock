//
//  ContentView.swift
//  FindTheRocks
//
//  Created by Nico Samuelson on 28/05/24.
//

import SwiftUI
import SwiftData
import MultipeerConnectivity

struct ContentView: View {
    @Binding var multipeerSession: MultipeerSession

    var body: some View {
        HomeView(multiPeerSession: $multipeerSession)
//        NavigationSplitView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//                    } label: {
//                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//                    }
//                }
////                .onDelete(perform: deleteItems)
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
////                    Button(action: addItem) {
////                        Label("Add Item", systemImage: "plus")
////                    }
//                }
//            }
//        } detail: {
//            Text("Select an item")
//        }
    }
}

//func receivedData(multipeerSession: MultipeerSession, _ data: Data, from peer: MCPeerID) {
//    
//    do {
//        if let player = try NSKeyedUnarchiver.unarchivedObject(ofClass: Player.self, from: data) {
////            peer.stopBrowsingForPeers()
//        }
////        if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
////            // Run the session with the received world map.
////            let configuration = ARWorldTrackingConfiguration()
////            configuration.planeDetection = [.horizontal, .vertical]
////            configuration.initialWorldMap = worldMap
////            sceneView.session.run(configuration, options: [.resetTracking])
////
////            // Remember who provided the map for showing UI feedback.
////            mapProvider = peer
////        }
////        else
////        if let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) {
////            // Add anchor to the session, ARSCNView delegate adds visible content.
////            //                sceneView.session.add(anchor: anchor)
////            // Get current device transform (position and orientation)
////            guard let currentFrame = sceneView.session.currentFrame else {
////                print("Couldn't get current frame")
////                return
////            }
////            let currentTransform = currentFrame.camera.transform
////
////            // Extract the translation and rotation components of the current transform
////            let currentTranslation = currentTransform.columns.3
////            let currentRotation = simd_quatf(currentTransform)
////
////            // Extract the translation and rotation components of the received anchor's transform
////            let anchorTranslation = anchor.transform.columns.3
////            let anchorRotation = simd_quatf(anchor.transform)
////
////            // Calculate the new position: your current position + the relative position of the anchor
////            let newTranslation = currentTranslation + anchorTranslation
////
////            // Combine the rotations: your current rotation * anchor's rotation
////            let newRotation = currentRotation * anchorRotation
////
////            // Construct the new transform with the combined translation and rotation
////            var newTransform = matrix_identity_float4x4
////            newTransform.columns.3 = newTranslation
////            newTransform = matrix_float4x4(newRotation)
////            newTransform.columns.3 = newTranslation
////
////            // Create a new anchor with the transformed position and orientation
////            let newAnchor = ARAnchor(name: anchor.name!, transform: newTransform)
////
////            // Add the transformed anchor to the session
////            sceneView.session.add(anchor: newAnchor)
////        }
////        else {
////            print("unknown data recieved from \(peer)")
////        }
//    } catch {
//        print("can't decode data recieved from \(peer)")
//    }
//}

//#Preview {
//    ContentView()
//}

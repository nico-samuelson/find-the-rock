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
    @State var room: Room = Room()

    var body: some View {
        HomeView(multiPeerSession: $multipeerSession)
//        PlantView(multiPeerSession: $multipeerSession)
        
//        HomeView(multiPeerSession: $multipeerSession)
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

//    } catch {
//        print("can't decode data recieved from \(peer)")
//    }
//}

//#Preview {
//    ContentView()
//}

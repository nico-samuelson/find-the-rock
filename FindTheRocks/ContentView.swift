//
//  ContentView.swift
//  FindTheRocks
//
//  Created by Nico Samuelson on 28/05/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State var multipeerSession: MultipeerSession = MultipeerSession(receivedDataHandler: receivedData)

    var body: some View {
        RoomView(multiPeerSession: $multipeerSession)
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

#Preview {
    ContentView()
}

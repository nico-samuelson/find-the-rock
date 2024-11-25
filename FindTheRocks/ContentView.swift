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
    @State private var navigateToHome = false

    var body: some View {
        VStack {
            if navigateToHome {
                HomeView(multiPeerSession: $multipeerSession)
            } else {
                SplashScreenView()
            }
        }
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                navigateToHome = true
                audio.playBGMusic()
            }
        }
    }
}

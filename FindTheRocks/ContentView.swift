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
    @Environment(AudioObservable.self) var audio
    @Binding var multipeerSession: MultipeerSession
    @State var room: Room = Room()
    @State var showSplashScreen = true

    var body: some View {
        Group{
            if showSplashScreen {
                SplashScreenView()
            }else {
                HomeView(multiPeerSession: $multipeerSession)
            }
        }.onAppear(){
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2){
                withAnimation(.easeOut(duration:0.3)){
                    showSplashScreen = false
                    audio.playBGMusic()
                }
            }
        }
        PlantView(multiPeerSession: $multipeerSession)
    }
}

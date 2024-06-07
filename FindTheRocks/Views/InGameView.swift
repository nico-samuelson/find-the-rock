//
//  InGameView.swift
//  FindTheRocks
//
//  Created by Sidi Praptama Aurelius Nurhalim on 03/06/24.
//

import UIKit
import SwiftUI
import SceneKit
import ARKit
import MultipeerConnectivity

//enum Mode {
//    case plant, inGame
//}

enum Label {
    case redTeam, blueTeam, fingTheRock
}

enum PlantButton {
    case real, fake
}

struct InGameView: View {
    @Environment(AudioObservable.self) var audio
    @Binding var multiPeerSession: MultipeerSession
    @State var selectedButton: PlantButton = PlantButton.real
    @State var plantTimeRemaining: Int = 5
    @State var seekTimeRemaining: Int = 5
    @State var countDownRemaining: Int = 3
    @State var isPlantTimerActive: Bool = false
    @State var isSeekTimerActive: Bool = false
    @State var isCountDownActive: Bool = false
    @State var isOver: Bool = false
    @State var redPoints: Int = 0
    @State var bluePoints: Int = 0
    
    let plantTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let seekTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let startCountDown = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func getPoint() {
        redPoints = multiPeerSession.room.teams[0].players.reduce(0) { $0 + $1.point }
        bluePoints = multiPeerSession.room.teams[1].players.reduce(0) { $0 + $1.point }
    }
    
    func changeModeToInGame() {
        withAnimation(.easeInOut(duration: 0.5)) {
            multiPeerSession.isPlanting = false
        }
    }
    
    func format(seconds: Int) -> String {
        String(format:"%d:%02d", seconds / 60, seconds % 60)
    }
    
    var body: some View {
        NavigationStack(){
            GeometryReader { gp in
                ZStack {
                    VStack(alignment: .leading) {
                        HStack {
                            VStack {
                                Text("\(format(seconds: plantTimeRemaining > 0 ? plantTimeRemaining : seekTimeRemaining))")
                                    .font(.custom("TitanOne", size: 30))
                                    .foregroundColor(Color.white)
                                    .onReceive(plantTimer) { _ in
                                        if plantTimeRemaining > 0 && isPlantTimerActive {
                                            plantTimeRemaining -= 1
                                        }
                                        else if seekTimeRemaining > 0 && isSeekTimerActive {
                                            seekTimeRemaining -= 1
                                        }
                                        else if plantTimeRemaining == 0 && multiPeerSession.isPlanting {
                                            isPlantTimerActive = false
                                            isCountDownActive = true
//                                            isSeekTimerActive = true
                                            multiPeerSession.isPlanting = false
                                        }
                                        else if seekTimeRemaining <= 0 {
                                            isOver = true
                                            print("game is over")
                                        }
                                    }
                            }
                            SkewedRoundedRectangle(topLeftYOffset: -2, topRightXOffset: -2, topRightYOffset: -0.5, bottomLeftXOffset: 2, cornerRadius: 10)
                                .frame(height: 40)
                                .foregroundStyle(!multiPeerSession.isPlanting ? Color.whiteGradient : multiPeerSession.getTeam(multiPeerSession.peerID) == 0 ? Color.redGradient : Color.blueGradient)
                                .overlay(
                                    Text(!multiPeerSession.isPlanting ? "FIND THE ROCK!" : multiPeerSession.getTeam(multiPeerSession.peerID) == 0 ? "RED TEAM PLANTING" : "BLUE TEAM PLANTING")
                                        .font(.custom("TitanOne", size: 20))
                                        .foregroundStyle(!multiPeerSession.isPlanting ? Color(hex: "CB9FF9") : Color.white)
                                        .fontWeight(.bold)
                                )
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                        }
                        
                        VStack(spacing: 0) {
                            // MARK: Score
                            if !multiPeerSession.isPlanting {
                                HStack(spacing: 0) {
                                    VStack {
                                        Text(!multiPeerSession.isPlanting ? "\(multiPeerSession.room.teams[0].players.reduce(0) { $0 + $1.point })" : "")
                                            .font(.custom("TitanOne", size: 40))
                                            .foregroundColor(Color.white)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .background(Color.redGradient)
                                    .cornerRadius(15, corners: [.topLeft])
                                    VStack {
                                        Text(!multiPeerSession.isPlanting ? "\(multiPeerSession.room.teams[1].players.reduce(0) { $0 + $1.point })" : "")
                                            .font(.custom("TitanOne", size: 40))
                                            .foregroundColor(Color.white)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .background(Color.blueGradient)
                                    .cornerRadius(15, corners: [.topRight])
                                }
                            }
                            
                            // MARK: AR View
                            ARControllerRepresentable(multipeerSession: $multiPeerSession)
                            //                                .background(Color.white)
                                .cornerRadius(15, corners: multiPeerSession.isPlanting && !isCountDownActive ? [.topLeft, .topRight, .bottomLeft, .bottomRight] : [.bottomLeft, .bottomRight])
                                .padding(.bottom, 20)
                        }
                        
                        // MARK: Rock selector
                        if multiPeerSession.isPlanting && !isCountDownActive {
                            HStack {
                                // Button Real Rock
                                VStack(spacing: 0) {
                                    VStack {
                                        Image("rock-1")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(15)
                                    .padding([.top, .leading, .trailing], 10)
                                    .padding(.bottom, 5)
                                    Text("Real Rock")
                                        .font(.custom("Staatliches-Regular", size: 26))
                                        .padding(.horizontal, 10)
                                        .foregroundColor(Color.white)
                                        .padding([.leading, .trailing], 5)
                                        .padding(.bottom, 0)
                                        .padding(.top, 5)
                                        .bold()
                                    
                                    Text("Remaining: \(multiPeerSession.room.realRock - multiPeerSession.room.teams[multiPeerSession.getTeam(multiPeerSession.peerID)].realPlanted.count)")
                                        .font(.custom("Staatliches-Regular", size: 15))
                                        .padding(.bottom, 5)
                                }
                                .frame(height: 140)
                                .background(!multiPeerSession.isPlantingFakeRock ? Color.tersierGradient.opacity(1) : Color.whiteGradient.opacity(0.2))
                                .cornerRadius(15)
                                .onTapGesture {
                                    audio.playClick()
                                    multiPeerSession.isPlantingFakeRock = false
                                }
                                
                                // Button Fake Rock
                                VStack(spacing: 0) {
                                    VStack {
                                        Image("rock-2")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(15)
                                    .padding([.top, .leading, .trailing], 10)
                                    .padding(.bottom, 5)
                                    Text("Fake Rock")
                                        .font(.custom("Staatliches-Regular", size: 26))
                                        .padding(.horizontal, 10)
                                        .foregroundColor(Color.white)
                                        .padding([.leading, .trailing], 5)
                                        .padding(.bottom, 0)
                                        .padding(.top, 5)
                                        .bold()
                                    Text("Remaining: \(multiPeerSession.room.fakeRock - multiPeerSession.room.teams[multiPeerSession.getTeam(multiPeerSession.peerID)].fakePlanted.count)")
                                        .font(.custom("Staatliches-Regular", size: 15))
                                        .padding(.bottom, 5)
                                }
                                .frame(height: 140)
                                .background(multiPeerSession.isPlantingFakeRock ? Color.tersierGradient.opacity(1) : Color.whiteGradient.opacity(0.2))
                                .cornerRadius(15)
                                .onTapGesture {
                                    audio.playClick()
                                    multiPeerSession.isPlantingFakeRock = true
                                }
                            }
                            .padding(.top, 10)
                        }
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.default, value: multiPeerSession.isPlanting)
                    .padding(.horizontal,20)
                    .padding(.vertical,0)
                    .onAppear {
                        isPlantTimerActive = true
                    }
                    
                    // Modal Countdown
                    if isCountDownActive {
                        VStack{
                            Spacer()
                            HStack{
                                Spacer()
                                VStack(alignment:.center){
                                    Text("\(countDownRemaining)")
                                        .font(.custom("TitanOne", size: 50))
                                        .foregroundColor(Color.white)
                                        .onReceive(startCountDown) { _ in
                                            if countDownRemaining <= 0 {
                                                isSeekTimerActive = true
                                                isCountDownActive = false
                                            } else {
                                                countDownRemaining -= 1
                                            }
                                        }
                                }
                                .frame(width:gp.size.width - 150, height: gp.size.height*0.23)
                                .background(){
                                    SkewedRoundedRectangle(topLeftXOffset: 5,topRightYOffset: 5,bottomRightYOffset: 5,cornerRadius: 20)
                                        .fill(Color.primaryGradient)
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                        .frame(width:gp.size.width,height:gp.size.height)
//                        .background(){
//                            Color.white.opacity(0.5)
//                                .blur(radius:10)
//                        }
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $isOver) {
                ResultView(multiPeerSession: $multiPeerSession)
            }
        }
        .background(Color.primaryGradient)
        .onAppear {
            self.multiPeerSession.isPlanting = true
            self.multiPeerSession.isGameStarted = true
            //            seekTimeRemaining = multiPeerSession.room.seekTime * 60
            //            plantTimeRemaining = multiPeerSession.room.hideTime * 60
        }
    }
}

struct ARControllerRepresentable: UIViewControllerRepresentable {
    @Binding var multipeerSession: MultipeerSession
    
    func makeUIViewController(context: Context) -> ARController {
        // Return an instance of your ARController
        return ARController(multipeerSession: multipeerSession)
    }
    
    func updateUIViewController(_ uiViewController: ARController, context: Context) {
        // Update the view controller if needed
    }
}

//#Preview {
//    InGameView()
//}

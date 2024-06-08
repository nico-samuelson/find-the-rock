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
struct InGameView: View {
    @Binding var multiPeerSession: MultipeerSession
    @State var myself: Player? = nil
    
    @State var redTeamTimeRemaining: Int = 10
    @State var blueTeamTimeRemaining: Int = 10
    @State var seekTimeRemaining: Int = 10
    @State var countDownRemaining: Int = 3
    @State var isPlantTimerActive: Bool = false
    @State var isSeekTimerActive: Bool = false
    @State var isCountDownActive: Bool = false
    @State var isOver: Bool = false
    
    @State var redPoints: Int = 0
    @State var bluePoints: Int = 0
    
    let redTeamTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let blueTeamTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var plantTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
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
                                if multiPeerSession.plantTurn == 0 && multiPeerSession.isPlanting {
                                    Text("\(format(seconds: redTeamTimeRemaining))")
                                        .font(.custom("TitanOne", size: 30))
                                        .foregroundColor(Color.white)
                                        .onReceive(redTeamTimer) { _ in
                                            if redTeamTimeRemaining > 0 {
                                                redTeamTimeRemaining -= 1
                                            }
                                            else {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    if multiPeerSession.getTeam(myself?.peerID) == multiPeerSession.plantTurn {
                                                        multiPeerSession.shareWorldMap()
                                                    }
                                                    multiPeerSession.plantTurn = 1
                                                    isCountDownActive = true
                                                }
                                                
                                            }
                                        }
                                }
                                else if !isCountDownActive && multiPeerSession.plantTurn == 1 && multiPeerSession.isPlanting {
                                    Text("\(format(seconds: blueTeamTimeRemaining))")
                                        .font(.custom("TitanOne", size: 30))
                                        .foregroundColor(Color.white)
                                        .onReceive(blueTeamTimer) { _ in
                                            if blueTeamTimeRemaining > 0 {
                                                blueTeamTimeRemaining -= 1
                                            }
                                            else {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    if multiPeerSession.getTeam(myself?.peerID) == multiPeerSession.plantTurn {
                                                        multiPeerSession.shareWorldMap()
                                                    }
                                                    multiPeerSession.isPlanting = false
                                                    isCountDownActive = true
                                                }
                                                
                                            }
                                        }
                                }
                                else if !isCountDownActive && !multiPeerSession.isPlanting {
                                    Text("\(format(seconds: seekTimeRemaining))")
                                        .font(.custom("TitanOne", size: 30))
                                        .foregroundColor(Color.white)
                                        .onReceive(seekTimer) { _ in
                                            if seekTimeRemaining > 0 && isSeekTimerActive {
                                                seekTimeRemaining -= 1
                                            }
                                            else if seekTimeRemaining <= 0 {
                                                isOver = true
                                                print("game is over")
                                            }
                                        }
                                }
                                else {
                                    Text("00:00")
                                        .font(.custom("TitanOne", size: 30))
                                        .foregroundColor(Color.white)
                                }
                            }
                            SkewedRoundedRectangle(topLeftYOffset: -2, topRightXOffset: -2, topRightYOffset: -0.5, bottomLeftXOffset: 2, cornerRadius: 10)
                                .frame(height: 40)
                                .foregroundStyle(!multiPeerSession.isPlanting ? Color.whiteGradient : multiPeerSession.plantTurn == 0 ? Color.redGradient : Color.blueGradient)
                                .overlay(
                                    Text(!multiPeerSession.isPlanting ? "FIND THE ROCK!" : multiPeerSession.plantTurn == 0 ? "RED TEAM PLANTING" : "BLUE TEAM PLANTING")
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
                                .cornerRadius(15, corners: multiPeerSession.isPlanting && !isCountDownActive ? [.allCorners] : [.bottomLeft, .bottomRight])
                                .padding(.bottom, 20)
                        }
                        
                        // MARK: Rock selector
                        if multiPeerSession.isPlanting && myself?.isPlanter ?? false &&  !isCountDownActive {
                            HStack {
                                // Button Real Rock
                                VStack(spacing: 0) {
                                    VStack {
                                        Image(systemName: "circle.fill")
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
                                    multiPeerSession.isPlantingFakeRock = false
                                }
                                
                                // Button Fake Rock
                                VStack(spacing: 0) {
                                    VStack {
                                        Image(systemName: "circle.fill")
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
                        myself = multiPeerSession.room.teams[multiPeerSession.getTeam(multiPeerSession.peerID)].players.first(where: {$0.peerID == multiPeerSession.peerID})
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
                                                countDownRemaining = 3
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
            // set initial game states
            self.multiPeerSession.isPlanting = true
            self.multiPeerSession.isGameStarted = true
            self.multiPeerSession.plantTurn = 0
            self.seekTimeRemaining = multiPeerSession.room.seekTime * 60
            self.redTeamTimeRemaining = multiPeerSession.room.hideTime * 60
            self.blueTeamTimeRemaining = multiPeerSession.room.hideTime * 60
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

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

enum Mode {
    case plant, inGame
}

enum Label {
    case redTeam, blueTeam, fingTheRock
}

enum PlantButton {
    case real, fake
}

struct InGameView: View {
    @State var selectedButton: PlantButton = PlantButton.real
    @State var timeRemaining: Int = 180
    @State var isTimerActive: Bool = false
    @State var mode: Mode = Mode.plant
    @State var redPoints: Int = 0
    @State var bluePoints: Int = 0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Binding var multiPeerSession: MultipeerSession
    @Binding var room: Room
    
    func getPoint() {
        redPoints = room.teams[0].players.reduce(0) { $0 + $1.point }
        bluePoints = room.teams[1].players.reduce(0) { $0 + $1.point }
    }
    
    func changeModeToInGame() {
        withAnimation(.easeInOut(duration: 0.5)) {
            mode = .inGame
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
                                Text("\(format(seconds: timeRemaining))")
                                    .font(.custom("TitanOne", size: 30))
                                    .foregroundColor(Color.white)
                                    .onReceive(timer) { _ in
                                        if timeRemaining > 0 && isTimerActive {
                                            timeRemaining -= 1
                                        } else {
                                            isTimerActive = false
                                        }
                                        
                                    }
                            }
                            SkewedRoundedRectangle(topLeftYOffset: -2, topRightXOffset: -2, topRightYOffset: -0.5, bottomLeftXOffset: 2, cornerRadius: 10)
                                .frame(height: 40)
                                .foregroundStyle(Color.whiteGradient)
                                .overlay(
                                    Text("FIND THE ROCK!")
                                        .font(.custom("TitanOne", size: 20))
                                        .foregroundColor(Color(hex: "CB9FF9"))
                                        .fontWeight(.bold)
                                )
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                        }
                        VStack(spacing: 0) {
                            // Score
                            HStack(spacing: 0) {
                                VStack {
                                    Text(mode == Mode.plant ? "\(room.teams[0].players.reduce(0) { $0 + $1.point })" : "")
                                        .font(.custom("TitanOne", size: 40))
                                        .foregroundColor(Color.white)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .background(Color.redGradient)
                                .cornerRadius(15, corners: [.topLeft])
                                VStack {
                                    Text(mode == Mode.plant ? "\(room.teams[1].players.reduce(0) { $0 + $1.point })" : "")
                                        .font(.custom("TitanOne", size: 40))
                                        .foregroundColor(Color.white)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .background(Color.blueGradient)
                                .cornerRadius(15, corners: [.topRight])
                            }
                            ARControllerRepresentable(multipeerSession: $multiPeerSession)
                                .background(Color.white)
                                .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
                                .padding(.bottom, 20)
                        }
                        
                        if mode == Mode.plant {
                            HStack {
                                // Button Real Rock
                                VStack {
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
                                        .padding([.bottom, .leading, .trailing], 10)
                                        .padding(.top, 5)
                                        .bold()
                                }
                                .frame(height: 100)
                                .background(selectedButton == PlantButton.real ? Color.tersierGradient.opacity(1) : Color.whiteGradient.opacity(0.2))
                                .cornerRadius(15)
                                .onTapGesture {
                                    selectedButton = PlantButton.real
                                }
                                
                                // Button Fake Rock
                                VStack {
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
                                        .padding([.bottom, .leading, .trailing], 10)
                                        .padding(.top, 5)
                                        .bold()
                                }
                                .frame(height: 100)
                                .background(selectedButton == PlantButton.fake ? Color.tersierGradient.opacity(1) : Color.whiteGradient.opacity(0.2))
                                .cornerRadius(15)
                                .onTapGesture {
                                    selectedButton = PlantButton.fake
                                    mode = Mode.inGame
                                }
                            }
                            .padding(.top, 10)
                        }
                        //                    else if mode == Mode.inGame  {
                        //
                        //
                        //                    }
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.default, value: mode)
                    .padding(.horizontal,20)
                    .padding(.vertical,0)
                    .onAppear {
                        isTimerActive = true
                    }
                    
                    // Modal Countdown
                    if timeRemaining <= 0 && mode == Mode.plant {
                        VStack{
                            Spacer()
                            HStack{
                                Spacer()
                                VStack(alignment:.center){
                                }
                                .frame(width:gp.size.width - 40, height: gp.size.height*0.23)
                                .background(){
                                    SkewedRoundedRectangle(topLeftXOffset: 5,topRightYOffset: 5,bottomRightYOffset: 5,cornerRadius: 20)
                                        .fill(Color.primaryGradient)
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                        .frame(width:gp.size.width,height:gp.size.height)
                            .background(){
                                Color.white.opacity(0.5)
                                    .blur(radius:10)
                        }
                    }
                }
            }
        }
        .background(Color.primaryGradient)
    }
}

//#Preview {
//    InGameView()
//}

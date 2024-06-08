//
//  ResultView.swift
//  FindTheRocks
//
//  Created by Nico Samuelson on 01/06/24.
//

import SwiftUI

struct ResultView: View {
    @Binding var multiPeerSession: MultipeerSession
    @State var winner: String = ""
    @State var playAgainPressed: Bool = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { gp in
                VStack(alignment: .center, spacing: 0) {
                    
                    Text("THE WINNER:")
                        .fontWeight(.bold)
                        .font(.custom("TitanOne", size: 40))
                        .foregroundStyle(.white)
                        .padding(.top, 10)
                        .padding(.bottom, 0)
                    
                    //MARK: Trophy
                    LegacySceneView(scene: Self.loadScene(named: "art.scnassets/models/champion.scn"))
                        .padding(20)
                    //                        .background(.white)
                    //                        .padding(20)
                    //                        .offset(y: -10)
                    SkewedRoundedRectangle(topLeftYOffset: -2, topRightXOffset: 5, topRightYOffset: 1, bottomLeftXOffset: -2, cornerRadius: 15)
                        .frame(height: 60)
                        .padding(.horizontal, 90)
                        .foregroundStyle(winner == "DRAW" ? Color.tersierGradient : winner == "RED TEAM" ? Color.redGradient : Color.blueGradient)
                        .overlay(
                            Text(winner)
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                                .font(.custom("Staatliches-Regular", size: 32))
                        )
                        .padding(.bottom, 30)
                    
                    HStack(spacing: 20) {
                        // MARK: Red team score
                        VStack(spacing: 0) {
                            SkewedRoundedRectangle(topRightXOffset: 10, topRightYOffset: -6, bottomRightXOffset: 8.5, bottomRightYOffset: 5, topRightCornerRadius: 20)
                                .frame(height: 40)
                                .foregroundStyle(Color.redGradient)
                                .overlay(
                                    Text("\(multiPeerSession.room.teams[0].players.map{$0.point}.reduce(0, +))")
                                        .foregroundStyle(.white)
                                        .fontWeight(.bold)
                                        .font(.custom("Staatliches-Regular", size: 24))
                                        .rotationEffect(.degrees(-2))
                                        .offset(x: -2, y: -2)
                                )
                            
                            List {
                                ForEach(multiPeerSession.room.teams[0].players.sorted { $0.point > $1.point }, id: \.peerID) { player in
                                    HStack(alignment: .center) {
                                        Circle()
                                            .foregroundStyle(Color.lightRed)
                                            .frame(width: 30, height: 30)
                                            .overlay {
                                                Circle()
                                                    .foregroundStyle(.white)
                                                    .padding(2)
                                            }
                                        
                                        Text(player.peerID.displayName.uppercased())
                                            .font(.custom("Staatliches-Regular", size: 14))
                                            .fontWeight(.medium)
                                            .lineLimit(0)
                                            .truncationMode(.tail)
                                            .rotationEffect(.degrees(-0.48))
                                        
                                        Spacer()
                                        
                                        SkewedRoundedRectangle(topRightYOffset: 0.5, bottomRightYOffset: -0.5, bottomLeftXOffset: 0.5, cornerRadius: 10)
                                            .foregroundStyle(Color.redGradient)
                                            .overlay(
                                                Text("\(player.point) pts")
                                                    .fontWeight(.bold)
                                                    .font(.custom("Staatliches-Regular", size: 14))
                                            )
                                            .padding(0)
                                            .frame(maxWidth: 50, maxHeight: 25)
                                    }
                                    .padding(0)
                                    //                                    .padding(.leading, -10)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(.none)
                                    .listRowSeparator(.hidden)
                                }
                                .padding(.top, 5)
                            }
                        }
                        .padding(.horizontal, -10)
                        .padding(.bottom, 10)
                        .listStyle(.plain)
                        .listRowSpacing(-3)
                        .scrollDisabled(false)
                        .scrollContentBackground(.hidden)
                        .scrollIndicators(.visible)
                        .background(
                            SkewedRoundedRectangle(topRightYOffset: -5, bottomRightXOffset: -5, topLeftCornerRadius: 20, topRightCornerRadius: 20, bottomRightCornerRadius: 20)
                                .foregroundStyle(.white.opacity(0.2))
                        )
                        //                        .padding(.leading, -10)
                        
                        // MARK: Blue team score
                        VStack(spacing: 0) {
                            SkewedRoundedRectangle(topLeftXOffset: 3.2, topLeftYOffset: -5, topRightYOffset: -5, bottomLeftXOffset: 4.5, topLeftCornerRadius: 20)
                                .frame(height: 35)
                                .foregroundStyle(Color.blueGradient)
                                .overlay(
                                    Text("\(multiPeerSession.room.teams[1].players.map{$0.point}.reduce(0, +))")
                                        .foregroundStyle(.white)
                                        .fontWeight(.bold)
                                        .font(.custom("Staatliches-Regular", size: 24))
                                        .rotationEffect(.degrees(-2))
                                        .offset(x: 2, y: -2)
                                )
                            
                            List {
                                ForEach(multiPeerSession.room.teams[1].players.sorted { $0.point > $1.point }, id: \.peerID) { player in
                                    HStack(alignment: .center) {
                                        Circle()
                                            .foregroundStyle(Color.lightBlue)
                                            .frame(width: 30, height: 30)
                                            .overlay {
                                                Circle()
                                                    .foregroundStyle(.white)
                                                    .padding(2)
                                            }
                                        
                                        Text(player.peerID.displayName.uppercased())
                                            .font(.custom("Staatliches-Regular", size: 14))
                                            .fontWeight(.medium)
                                            .lineLimit(0)
                                            .truncationMode(.tail)
                                            .rotationEffect(.degrees(-0.48))
                                        
                                        Spacer()
                                        
                                        SkewedRoundedRectangle(topRightYOffset: 0.5, bottomRightYOffset: -0.5, bottomLeftXOffset: 0.5, cornerRadius: 10)
                                            .foregroundStyle(Color.blueGradient)
                                            .overlay(
                                                Text("\(player.point) pts")
                                                    .fontWeight(.bold)
                                                    .font(.custom("Staatliches-Regular", size: 14))
                                            )
                                            .padding(0)
                                            .frame(maxWidth: 50, maxHeight: 25)
                                    }
                                    .padding(0)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(.none)
                                    .listRowSeparator(.hidden)
                                }
                                .padding(.top, 5)
                            }
                        }
                        .padding(.horizontal, -8)
                        .padding(.bottom, 10)
                        .listStyle(.plain)
                        .listRowSpacing(-3)
                        .scrollDisabled(false)
                        .scrollContentBackground(.hidden)
                        .scrollIndicators(.visible)
                        .background(
                            SkewedRoundedRectangle(topLeftXOffset: -5, topLeftYOffset: -5, topRightYOffset: -5, bottomRightXOffset: -5, topLeftCornerRadius: 20, bottomLeftCornerRadius: 20)
                                .foregroundStyle(.white.opacity(0.2))
                        )
                    }
                    .frame(height: 170)
                    
                    NavigationLink(destination: HomeView(multiPeerSession: $multiPeerSession), label: {
                        SkewedRoundedRectangle(topRightYOffset: -2, bottomRightXOffset: -3, bottomRightYOffset: -1, cornerRadius: 20)
                            .frame(maxHeight: 60)
                            .padding(.horizontal, 60)
                            .foregroundStyle(.white)
                            .overlay(
                                Text("MAIN MENU")
                                    .foregroundStyle(Color.primaryPurple)
                                    .fontWeight(.bold)
                                    .font(.custom("Staatliches-Regular", size: 32))
                            )
                    })
                    .padding(.top, 30)
                    
                    Button {
                        // reset all point and rocks
                        for i in 0...1 {
                            multiPeerSession.room.teams[i].fakePlanted.removeAll()
                            multiPeerSession.room.teams[i].realPlanted.removeAll()
                            
                            for player in multiPeerSession.room.teams[i].players {
                                player.point = 0
                            }
                            
                            self.multiPeerSession.syncRoom()
                        }
                    } label: {
                        SkewedRoundedRectangle(topRightYOffset: -5, bottomRightXOffset: 3, bottomRightYOffset: 3, bottomLeftXOffset: 6, cornerRadius: 20)
                            .frame(maxHeight: 75)
                            .padding(.horizontal, 50)
                            .foregroundStyle(Color.tersierGradient)
                            .overlay(
                                Text("PLAY AGAIN")
                                    .foregroundStyle(Color.white)
                                    .fontWeight(.bold)
                                    .font(.custom("Staatliches-Regular", size: 32))
                            )
                            .padding(.top, 15)
                            .padding(.bottom, 25)
                    }
                    .navigationDestination(isPresented: $playAgainPressed) {
                        multiPeerSession.isMaster ?
                        AnyView(RoomView(multiPeerSession: $multiPeerSession, myself:Player(peerID: multiPeerSession.getPeerId(), profile:"lancelot-avatar", status: .connected, point: 0, isPlanter: true))) :
                        AnyView(WaitingView(multiPeerSession: $multiPeerSession))
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .background(Color.primaryGradient)
        }
        .onAppear(perform: {
            let redTeamScore = multiPeerSession.room.teams[0].players.reduce(0) { $0 + $1.point }
            let blueTeamScore = multiPeerSession.room.teams[1].players.reduce(0) { $0 + $1.point }
            if redTeamScore == blueTeamScore {
                winner = "DRAW"
            }
            else {
                winner = redTeamScore > blueTeamScore ? "RED TEAM" : "BLUE TEAM"
            }
            
            playAgainPressed = false
        })
        
    }
}

//#Preview {
//    ResultView()
//}

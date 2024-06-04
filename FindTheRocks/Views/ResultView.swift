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
    
    var body: some View {
        NavigationStack {
            GeometryReader { gp in
                VStack(alignment: .center) {
                    
                    Text("THE WINNER:")
                        .fontWeight(.bold)
                        .font(.system(size: 44))
                        .foregroundStyle(.white)
                        .padding(.top, 10)
                    
                    //MARK: Trophy
                    Image(systemName: "trophy.fill")
                        .resizable()
                        .foregroundStyle(.yellow)
                        .frame(width: 150, height: 150)
                    
                    SkewedRoundedRectangle(topLeftYOffset: -2, topRightXOffset: 5, topRightYOffset: 1, bottomLeftXOffset: -2, cornerRadius: 15)
                        .frame(height: 60)
                        .padding(.horizontal, 90)
                        .padding(.vertical, 30)
                        .foregroundStyle(winner == "DRAW" ? Color.tersierGradient : winner == "RED TEAM" ? Color.redGradient : Color.blueGradient)
                        .overlay(
                            Text(winner)
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                                .font(.system(size: 32))
                        )
                    
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
                                        .font(.system(size: 24))
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
                                            .font(.system(size: 14))
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
                                                .font(.system(size: 14))
                                        )
                                        .padding(0)
                                        .frame(maxWidth: 50, maxHeight: 25)
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(.none)
                                    .listRowSeparator(.hidden)
                                }
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
                        
                        // MARK: Blue team score
                        VStack(spacing: 0) {
                            SkewedRoundedRectangle(topLeftXOffset: 3.2, topLeftYOffset: -5, topRightYOffset: -5, bottomLeftXOffset: 4.5, topLeftCornerRadius: 20)
                                .frame(height: 35)
                                .foregroundStyle(Color.blueGradient)
                                .overlay(
                                    Text("\(multiPeerSession.room.teams[1].players.map{$0.point}.reduce(0, +))")
                                        .foregroundStyle(.white)
                                        .fontWeight(.bold)
                                        .font(.system(size: 24))
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
                                            .font(.system(size: 14))
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
                                                .font(.system(size: 14))
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
                                    .font(.system(size: 32))
                            )
                    })
                    .padding(.top, 30)
                    
                    NavigationLink(destination: RoomView(multiPeerSession: $multiPeerSession, myself:Player(peerID: multiPeerSession.getPeerId(), profile:"lancelot-avatar", status: .connected, point: 0)),label:{
                        SkewedRoundedRectangle(topRightYOffset: -5, bottomRightXOffset: 3, bottomRightYOffset: 3, bottomLeftXOffset: 6, cornerRadius: 20)
                            .frame(maxHeight: 75)
                            .padding(.horizontal, 50)
                            .foregroundStyle(Color.tersierGradient)
                            .overlay(
                                Text("PLAY AGAIN")
                                    .foregroundStyle(Color.white)
                                    .fontWeight(.bold)
                                    .font(.system(size: 32))
                            )
                            .padding(.top, 15)
                            .padding(.bottom, 25)
                    })
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
        })
        
    }
}

//#Preview {
//    ResultView()
//}

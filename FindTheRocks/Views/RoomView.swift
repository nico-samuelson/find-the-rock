//
//  RoomView.swift
//  FindTheRocks
//
//  Created by Nico Samuelson on 28/05/24.
//

import SwiftUI
import MultipeerConnectivity

struct RoomView: View {
    @State var redTeam : [MCPeerID] = []
    @State var blueTeam: [MCPeerID] = []
    @Binding var multiPeerSession: MultipeerSession
    @State var nearbyPeers: [MCPeerID] = []
    
    var body: some View {
        NavigationStack {
            GeometryReader { gp in
                VStack(alignment: .leading) {
                    HStack {
                        Text("Players")
                            .font(.system(size: 40))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "gear")
                            .foregroundColor(.white)
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    }
                    .padding(10)
                    .padding(.horizontal, 25)
                    
                    
                    HStack(spacing: 20) {
                        VStack(spacing: 0) {
                            SkewedRoundedRectangle(topRightXOffset: 10, topRightYOffset: -6, bottomRightXOffset: 8.5, bottomRightYOffset: 5, topRightCornerRadius: 20)
                                .frame(height: 60)
                                .foregroundStyle(Color.redGradient)
                                .overlay(
                                    Text("RED TEAM")
                                        .foregroundStyle(.white)
                                        .fontWeight(.bold)
                                        .font(.system(size: 24))
                                        .rotationEffect(.degrees(-2))
                                        .offset(x: -2, y: -2)
                                )
                            
                            List {
                                ForEach(redTeam, id: \.self) { player in
                                    HStack(alignment: .center) {
                                        Circle()
                                            .foregroundStyle(Color.lightRed)
                                            .frame(width: 25, height: 25)
                                            .overlay {
                                                Circle()
                                                    .foregroundStyle(.white)
                                                    .padding(2)
                                            }
                                        
                                        Text(player.displayName.uppercased())
                                            .font(.system(size: 12))
                                            .fontWeight(.medium)
                                            .lineLimit(0)
                                            .truncationMode(.tail)
                                            .rotationEffect(.degrees(-0.48))
                                        
                                        Button{} label: {
                                            SkewedRoundedRectangle(topRightYOffset: 0.5, bottomRightYOffset: -0.5, bottomLeftXOffset: 0.5,
                                                                   topLeftCornerRadius: 10,
                                                                   topRightCornerRadius: 10,
                                                                   bottomLeftCornerRadius: 10,
                                                                   bottomRightCornerRadius: 10)
                                            .foregroundStyle(.white)
                                            .overlay(
                                                Image(systemName: "xmark")
                                                    .resizable()
                                                    .frame(width: 10, height: 10)
                                                    .foregroundStyle(Color.primaryGradient)
                                            )
                                        }
                                        .padding(0)
                                        .frame(maxWidth: 25, maxHeight: 25)
                                        
                                        Button{} label: {
                                            SkewedRoundedRectangle(topRightYOffset: 0.5, bottomRightYOffset: -0.5, bottomLeftXOffset: 0.5,
                                                                   topLeftCornerRadius: 10,
                                                                   topRightCornerRadius: 10,
                                                                   bottomLeftCornerRadius: 10,
                                                                   bottomRightCornerRadius: 10)
                                            .foregroundStyle(Color.tersierGradient)
                                            .overlay(
                                                Image(systemName: "chevron.right")
                                                    .resizable()
                                                    .frame(width: 7.5, height: 13.5)
                                                    .foregroundStyle(.white)
                                            )
                                        }
                                        .padding(0)
                                        .frame(maxWidth: 25, maxHeight: 25)
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
                        .listRowSpacing(-6)
                        .scrollDisabled(false)
                        .scrollContentBackground(.hidden)
                        .scrollIndicators(.visible)
                        .background(
                            SkewedRoundedRectangle(topRightYOffset: -5, bottomRightXOffset: -5, topLeftCornerRadius: 20, topRightCornerRadius: 20, bottomRightCornerRadius: 20)
                                .foregroundStyle(.white.opacity(0.2))
                        )
                        
                        VStack(spacing: 0) {
                            SkewedRoundedRectangle(topLeftXOffset: 3.2, topLeftYOffset: -5, topRightYOffset: -10, bottomRightYOffset: 5, bottomLeftXOffset: 4.5, topLeftCornerRadius: 20)
                                .frame(height: 55)
                                .foregroundStyle(Color.blueGradient)
                                .overlay(
                                    Text("BLUE TEAM")
                                        .foregroundStyle(.white)
                                        .fontWeight(.bold)
                                        .font(.system(size: 24))
                                        .rotationEffect(.degrees(-2))
                                        .offset(x: 2, y: -2)
                                )
                            
                            List {
                                ForEach(blueTeam, id: \.self) { player in
                                    HStack(alignment: .center) {
                                        Button{} label: {
                                            SkewedRoundedRectangle(topRightYOffset: 0.5, bottomRightYOffset: -0.5, bottomLeftXOffset: 0.5, cornerRadius: 10)
                                            .foregroundStyle(Color.tersierGradient)
                                            .overlay(
                                                Image(systemName: "chevron.left")
                                                    .resizable()
                                                    .frame(width: 7.5, height: 13.5)
                                                    .foregroundStyle(.white)
                                            )
                                        }
                                        .padding(0)
                                        .frame(maxWidth: 25, maxHeight: 25)
                                        
                                        Button{} label: {
                                            SkewedRoundedRectangle(topRightYOffset: 0.5, bottomRightYOffset: -0.5, bottomLeftXOffset: 0.5, cornerRadius: 10)
                                            .foregroundStyle(.white)
                                            .overlay(
                                                Image(systemName: "xmark")
                                                    .resizable()
                                                    .frame(width: 10, height: 10)
                                                    .foregroundStyle(Color.primaryGradient)
                                            )
                                        }
                                        .padding(0)
                                        .frame(maxWidth: 25, maxHeight: 25)
                                        
                                        Text(player.displayName.uppercased())
                                            .font(.system(size: 12))
                                            .fontWeight(.medium)
                                            .lineLimit(0)
                                            .truncationMode(.tail)
                                            .rotationEffect(.degrees(-0.48))
                                        
                                        Circle()
                                            .foregroundStyle(Color.lightBlue)
                                            .frame(width: 25, height: 25)
                                            .overlay {
                                                Circle()
                                                    .foregroundStyle(.white)
                                                    .padding(2)
                                            }
                                    }
                                    .padding(0)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(.none)
                                    .listRowSeparator(.hidden)
                                }
                            }
                        }
                        .padding(.horizontal, -8)
                        .padding(.bottom, 10)
                        .listStyle(.plain)
                        .listRowSpacing(-6)
                        .scrollDisabled(false)
                        .scrollContentBackground(.hidden)
                        .scrollIndicators(.visible)
                        .background(
                            SkewedRoundedRectangle(topLeftXOffset: -5, topLeftYOffset: -5, topRightYOffset: -10, bottomRightXOffset: -5, topLeftCornerRadius: 20, bottomLeftCornerRadius: 20)
                                .foregroundStyle(.white.opacity(0.2))
                        )
                    }
                    .frame(maxHeight: 170)
                    
                    Text("Nearby")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(10)
                        .padding(.horizontal, 25)
                    
                    List {
                        ForEach(self.nearbyPeers, id: \.self) { peer in
                            HStack {
                                Circle()
                                    .foregroundStyle(.white.opacity(0.5))
                                    .frame(width: 40, height: 40)
                                    .overlay {
                                        Circle()
                                            .foregroundStyle(.white)
                                            .padding(4)
                                    }
                                
                                Text(peer.displayName.uppercased())
                                    .foregroundStyle(.black)
                                    .fontWeight(.medium)
                                    .font(.system(size: 20))
                                    .padding(.leading, 5)
                                
                                Spacer()
                                
                                Button{} label: {
                                    SkewedRoundedRectangle(topRightYOffset: 0.5, bottomRightXOffset: 2, bottomRightYOffset: -1, bottomLeftXOffset: 3, topLeftCornerRadius: 10, topRightCornerRadius: 10, bottomLeftCornerRadius: 10, bottomRightCornerRadius: 10)
                                        .foregroundStyle(Color.tersierGradient)
                                        .overlay(
                                            Text("INVITE")
                                                .foregroundStyle(.white)
                                                .fontWeight(.bold)
                                                .font(.system(size: 16))
                                        )
                                }
                                .padding(0)
                                .frame(maxWidth: 100, maxHeight: 30)
                            }
                        }
                        .scrollDisabled(false)
                        .scrollIndicators(.visible)
                        .padding(0)
                        .listRowBackground(Color.clear)
                        .listRowInsets(.none)
                        .listRowSeparator(.hidden)
                    }
                    .padding(20)
                    .listRowSpacing(-10)
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .background(
                        SkewedRoundedRectangle(topLeftXOffset: 20, topRightXOffset: 22, bottomRightXOffset: 20, bottomLeftXOffset: 25, cornerRadius: 20)
                            .foregroundStyle(.white.opacity(0.2))
                    )
                    .frame(maxHeight: 250)
                    
                    Button{} label: {
                        SkewedRoundedRectangle(topRightYOffset: -2, bottomRightXOffset: -3, bottomRightYOffset: -1, cornerRadius: 20)
                            .frame(maxHeight: 60)
                            .padding(.horizontal, 60)
                            .foregroundStyle(.white)
                            .overlay(
                                Text("BACK")
                                    .foregroundStyle(Color.primaryPurple)
                                    .fontWeight(.bold)
                                    .font(.system(size: 40))
                            )
                    }
                    .padding(.top, 30)
                    
                    Button{} label: {
                        SkewedRoundedRectangle(topRightYOffset: -5, bottomRightXOffset: 3, bottomRightYOffset: 3, bottomLeftXOffset: 6, cornerRadius: 20)
                            .frame(maxHeight: 75)
                            .padding(.horizontal, 50)
                            .foregroundStyle(Color.tersierGradient)
                            .overlay(
                                Text("START")
                                    .foregroundStyle(Color.white)
                                    .fontWeight(.bold)
                                    .font(.system(size: 40))
                            )
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 25)
                }
                .background(Color.primaryGradient)
            }
        }
        .onChange(of: multiPeerSession.detectedPeers) { peers in
            self.nearbyPeers = peers
        }
        .onAppear(perform: {
            self.nearbyPeers = multiPeerSession.detectedPeers
        })
    }
}

//#Preview {
//    RoomView()
//}

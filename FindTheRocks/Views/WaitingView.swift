//
//  WaitingView.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 03/06/24.
//

import SwiftUI
import MultipeerConnectivity

struct WaitingView: View {
    @Binding var multiPeerSession:MultipeerSession
    @State var isDestroyed = false
    @State var message:String = "destroy"
    @State var navigateToHome = false
    
    var body: some View {
        NavigationStack{
            GeometryReader{ gp in
                ZStack{
                    VStack(alignment: .center){
                        Spacer()
                        // MARK: Room Title
                        Text(multiPeerSession.room.name.isEmpty ? "Waiting..." : multiPeerSession.room.name)
                            .font(.custom("TitanOne",size:40))
                            .foregroundStyle(.white)
                            .bold()
                        Spacer()
                        // MARK: Team
                        HStack(spacing: 20) {
                            // MARK: Red team
                            VStack(spacing: 0) {
                                SkewedRoundedRectangle(topRightXOffset: 10, topRightYOffset: -6, bottomRightXOffset: 8.5, bottomRightYOffset: 5, topRightCornerRadius: 20)
                                    .frame(height: 60)
                                    .foregroundStyle(Color.redGradient)
                                    .overlay(
                                        Text("RED TEAM")
                                            .foregroundStyle(.white)
                                            .fontWeight(.bold)
                                            .font(.custom("Staatliches-Regular",size: 32))
                                            .rotationEffect(.degrees(-2))
                                            .offset(x: -2, y: -2)
                                    )
                                
                                List {
                                    ForEach(multiPeerSession.room.teams[0].players.filter({ $0.status == .connected }), id: \.peerID) { player in
                                        HStack(alignment: .center) {
                                            Circle()
                                                .foregroundStyle(Color.lightRed)
                                                .frame(width: 25, height: 25)
                                                .overlay {
                                                    Circle()
                                                        .foregroundStyle(.white)
                                                        .padding(2)
                                                }
                                            
                                            Text(player.peerID.displayName.uppercased())
                                                .font(.custom("Staatliches-Regular",size: 18))
                                                .fontWeight(.medium)
                                                .lineLimit(0)
                                                .truncationMode(.tail)
                                                .rotationEffect(.degrees(-0.48))
                                            
                                            Spacer()
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
                            
                            // MARK: Blue team
                            VStack(spacing: 0) {
                                SkewedRoundedRectangle(topLeftXOffset: 3.2, topLeftYOffset: -5, topRightYOffset: -10, bottomRightYOffset: 5, bottomLeftXOffset: 4.5, topLeftCornerRadius: 20)
                                    .frame(height: 55)
                                    .foregroundStyle(Color.blueGradient)
                                    .overlay(
                                        Text("BLUE TEAM")
                                            .foregroundStyle(.white)
                                            .fontWeight(.bold)
                                            .font(.custom("Staatliches-Regular",size: 32))
                                            .rotationEffect(.degrees(-2))
                                            .offset(x: 2, y: -2)
                                    )
                                
                                List {
                                    ForEach(multiPeerSession.room.teams[1].players.filter({ $0.status == .connected }), id: \.peerID) { player in
                                        HStack(alignment: .center) {
                                            Spacer()
                                            Text(player.peerID.displayName.uppercased())
                                                .font(.custom("Staatliches-Regular",size: 18))
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
                        .frame(maxHeight: 200)
                        Spacer()
                        // MARK: BACK BUTTON
                        Button(action: {
                            // Your custom logic here
                            // e.g., update some state, print a message, etc.
                            print("Logic Executed, destroying room!")
                            multiPeerSession.quitRoom()
                            
                            // After your logic, set navigateToHome to true to trigger navigation
                            navigateToHome = true
                        }) {
                            SkewedRoundedRectangle(topRightYOffset: -2, bottomRightXOffset: -3, bottomRightYOffset: -1, cornerRadius: 20)
                                .frame(maxHeight: 60)
                                .padding(.horizontal, 60)
                                .foregroundStyle(.white)
                                .overlay(
                                    Text("BACK")
                                        .foregroundStyle(Color.primaryPurple)
                                        .fontWeight(.bold)
                                        .font(.custom("Staatliches-Regular",size: 32))
                                )
                                .padding(.top, 30)
                        }
                        .navigationDestination(isPresented: $navigateToHome){
                            HomeView(multiPeerSession: $multiPeerSession)
                        }
                        Spacer()
                    }
                    if isDestroyed {
                        VStack{
                            Spacer()
                            HStack{
                                Spacer()
                                VStack(alignment:.center){
                                    Spacer()
                                        .frame(height:12)
                                    Text("NOTICE")
                                        .font(.custom("TitanOne",size:22))
                                        .foregroundStyle(.white)
                                        .bold()
                                    Spacer()
                                    Text(message == "destroy" ? "The room is destroyed by the room master!" : "You have been kicked from the room!")
                                        .font(.custom("Staatliches-Regular",size:18))
                                        .foregroundStyle(.white)
                                        .bold()
                                    Spacer()
                                    NavigationLink(destination: HomeView(multiPeerSession: $multiPeerSession),label:{
                                        Text("Okay")
                                            .font(.custom("Staatliches-Regular",size:18,relativeTo: .title))
                                            .foregroundStyle(.white)
                                            .bold()
                                            .frame(width:gp.size.width - 80,height:40)
                                            .background(){
                                                SkewedRoundedRectangle(topLeftYOffset: 2,bottomRightXOffset: 2,bottomLeftXOffset: 2,cornerRadius: 10)
                                                    .fill(Color.tersierGradient)
                                            }
                                    })
                                    Spacer()
                                        .frame(height:20)
                                }
                                .frame(width:gp.size.width - 40, height: gp.size.height*0.18)
                                .background(){
                                    SkewedRoundedRectangle(topLeftXOffset: 5,topRightYOffset: 5,bottomRightYOffset: 5,cornerRadius: 20)
                                        .fill(Color.primaryGradient)
                                }
                                Spacer()
                            }
                            Spacer()
                        }.frame(width:gp.size.width,height:gp.size.height)
                            .background(){
                                Color.white.opacity(0.5)
                                    .blur(radius:10)
                            }
                    }
                }
            }
        }
        .onAppear(){
            multiPeerSession.showDestroyModal = {text in
                message = text
                isDestroyed = true
            }
            multiPeerSession.isPlanting = false
            multiPeerSession.isGameStarted = false
        }
        .background(Color.primaryGradient)
        .navigationBarBackButtonHidden()
        .navigationDestination(isPresented: $multiPeerSession.isGameStarted) {
            InGameView(multiPeerSession: $multiPeerSession)
        }
    }
}

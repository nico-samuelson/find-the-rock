//
//  RoomView.swift
//  FindTheRocks
//
//  Created by Nico Samuelson on 28/05/24.
//

import SwiftUI
import MultipeerConnectivity

struct RoomView: View {
    @Binding var multiPeerSession: MultipeerSession
    @State var myself: Player
    @State private var navigateToHome = false
    @State private var isSettingSheet = false
    
    func assignToTeam(player: Player, to: Int = -1) {
        print("player: ", player)
        print("to: ", to)
        // assign player to team after invite
        if to == -1 {
            multiPeerSession.invitePeer(peerID: player.peerID, data: try! NSKeyedArchiver.archivedData(withRootObject: Player(peerID: multiPeerSession.getPeerId(), profile: "lancelot-avatar", status: .connected, point:0 ), requiringSecureCoding: true))
        }
        
        // move player to another team
        else {
            let from = to == 0 ? 1 : 0
            multiPeerSession.room.teams[from].players.removeAll(where: { $0.peerID == player.peerID })
            multiPeerSession.room.teams[to].players.append(player)
            multiPeerSession.syncRoom()
        }
    }
    
    func kickPlayer(player: Player) {
        print("kicked")
        let message: String = "kicked"
        multiPeerSession.notifyPeer(peer: player.peerID, data: message.data(using: .utf8)!)
        multiPeerSession.room.teams[0].players.removeAll(where: { $0.peerID == player.peerID })
        multiPeerSession.room.teams[1].players.removeAll(where: { $0.peerID == player.peerID })
        multiPeerSession.syncRoom()
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { gp in
                VStack(alignment: .leading) {
                    HStack {
                        Text(multiPeerSession.room.name)
                            .font(.custom("TitanOne",size: 40))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "gear")
                            .foregroundColor(.white)
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .onTapGesture {
                                isSettingSheet = true
                            }
                        
                    }
                    .padding(10)
                    .padding(.horizontal, 25)
                    
                    
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
                                            .font(.custom("Staatliches-Regular",size: 21))
                                            .fontWeight(.medium)
                                            .lineLimit(0)
                                            .truncationMode(.tail)
                                            .rotationEffect(.degrees(-0.48))
                                        
                                        Spacer()
                                        if player.peerID != multiPeerSession.getPeerId() {
                                            SkewedRoundedRectangle(topRightYOffset: 0.5, bottomRightYOffset: -0.5, bottomLeftXOffset: 0.5,
                                                                   topLeftCornerRadius: 10,
                                                                   topRightCornerRadius: 10,
                                                                   bottomLeftCornerRadius: 10,
                                                                   bottomRightCornerRadius: 10)
                                            .foregroundStyle(.white)
                                            .frame(width: 25, height: 25)
                                            .overlay(
                                                Image(systemName: "xmark")
                                                    .resizable()
                                                    .frame(width: 10, height: 10)
                                                    .foregroundStyle(Color.primaryGradient)
                                            )
                                            .onTapGesture{
                                                kickPlayer(player: player)
                                            }
                                        }
                                        SkewedRoundedRectangle(topRightYOffset: 0.5, bottomRightYOffset: -0.5, bottomLeftXOffset: 0.5,
                                                               topLeftCornerRadius: 10,
                                                               topRightCornerRadius: 10,
                                                               bottomLeftCornerRadius: 10,
                                                               bottomRightCornerRadius: 10)
                                        .foregroundStyle(Color.tersierGradient)
                                        .frame(width: 25, height: 25)
                                        .overlay(
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .frame(width: 10, height: 10)
                                                .foregroundStyle(Color.white)
                                        )
                                        .onTapGesture{
                                            assignToTeam(player: player, to: 1)
                                        }
                                        
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
                                        SkewedRoundedRectangle(topRightYOffset: 0.5, bottomRightYOffset: -0.5, bottomLeftXOffset: 0.5,
                                                               topLeftCornerRadius: 10,
                                                               topRightCornerRadius: 10,
                                                               bottomLeftCornerRadius: 10,
                                                               bottomRightCornerRadius: 10)
                                        .foregroundStyle(Color.tersierGradient)
                                        .frame(width: 25, height: 25)
                                        .overlay(
                                            Image(systemName: "chevron.left")
                                                .resizable()
                                                .frame(width: 10, height: 10)
                                                .foregroundStyle(Color.white)
                                        )
                                        .onTapGesture{
                                            assignToTeam(player: player, to: 0)
                                        }
                                        
                                        if player.peerID != multiPeerSession.getPeerId() {
                                            SkewedRoundedRectangle(topRightYOffset: 0.5, bottomRightYOffset: -0.5, bottomLeftXOffset: 0.5,
                                                                   topLeftCornerRadius: 10,
                                                                   topRightCornerRadius: 10,
                                                                   bottomLeftCornerRadius: 10,
                                                                   bottomRightCornerRadius: 10)
                                            .foregroundStyle(.white)
                                            .frame(width: 25, height: 25)
                                            .overlay(
                                                Image(systemName: "xmark")
                                                    .resizable()
                                                    .frame(width: 10, height: 10)
                                                    .foregroundStyle(Color.primaryGradient)
                                            )
                                            .onTapGesture{
                                                kickPlayer(player: player)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Text(player.peerID.displayName.uppercased())
                                            .font(.custom("Staatliches-Regular",size: 21))
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
                    
                    //MARK: Nearby
                    Text("Nearby")
                        .font(.custom("TitanOne",size: 38))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(10)
                        .padding(.horizontal, 25)
                    
                    List {
                        ForEach(Array(multiPeerSession.detectedPeers.filter({ $0.status == .disconnected })), id: \.peerID) { peer in
                            HStack {
                                Circle()
                                    .foregroundStyle(.white.opacity(0.5))
                                    .frame(width: 40, height: 40)
                                    .overlay {
                                        Circle()
                                            .foregroundStyle(.white)
                                            .padding(4)
                                    }
                                
                                Text(peer.peerID.displayName.uppercased())
                                    .foregroundStyle(.black)
                                    .fontWeight(.medium)
                                    .font(.custom("Staatliches-Regular",size: 21))
                                    .padding(.leading, 5)
                                
                                Spacer()
                                
                                Button{
                                    assignToTeam(player: peer)
                                } label: {
                                    SkewedRoundedRectangle(topRightYOffset: 0.5, bottomRightXOffset: 2, bottomRightYOffset: -1, bottomLeftXOffset: 3, topLeftCornerRadius: 10, topRightCornerRadius: 10, bottomLeftCornerRadius: 10, bottomRightCornerRadius: 10)
                                        .foregroundStyle(Color.tersierGradient)
                                        .overlay(
                                            Text("INVITE")
                                                .foregroundStyle(.white)
                                                .fontWeight(.bold)
                                                .font(.custom("Staatliches-Regular",size: 18))
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
                    
                    // MARK: BACK DESTROY ROOM
                    Button(action: {
                        // Your custom logic here
                        // e.g., update some state, print a message, etc.
                        print("Logic Executed, destroying room!")
                        multiPeerSession.destroyRoom()
                        
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
                                    .font(.custom("Staatliches-Regular",size: 36))
                            )
                            .padding(.top, 30)
                    }
                    .navigationDestination(isPresented: $navigateToHome){
                        HomeView(multiPeerSession: $multiPeerSession)
                    }
                    
                    // MARK: GO TO CONFIG ROOM
                    NavigationLink(destination: ResultView(multiPeerSession: $multiPeerSession),label:{
                        SkewedRoundedRectangle(topRightYOffset: -5, bottomRightXOffset: 3, bottomRightYOffset: 3, bottomLeftXOffset: 6, cornerRadius: 20)
                            .frame(maxHeight: 75)
                            .padding(.horizontal, 50)
                            .foregroundStyle(Color.tersierGradient)
                            .overlay(
                                Text("START")
                                    .foregroundStyle(Color.white)
                                    .fontWeight(.bold)
                                    .font(.custom("Staatliches-Regular",size: 36))
                            )
                            .padding(.top, 15)
                            .padding(.bottom, 25)
                    })
//                    Button{} label: {
//                        SkewedRoundedRectangle(topRightYOffset: -5, bottomRightXOffset: 3, bottomRightYOffset: 3, bottomLeftXOffset: 6, cornerRadius: 20)
//                            .frame(maxHeight: 75)
//                            .padding(.horizontal, 50)
//                            .foregroundStyle(Color.tersierGradient)
//                            .overlay(
//                                Text("START")
//                                    .foregroundStyle(Color.white)
//                                    .fontWeight(.bold)
//                                    .font(.system(size: 40))
//                            )
//                    }
//                    .padding(.top, 15)
//                    .padding(.bottom, 25)
                }
                .background(Color.primaryGradient)
            }
            .navigationBarBackButtonHidden()
            .fullScreenCover(isPresented: $isSettingSheet, content: {
                RoomSettingSheetView(multiPeerSession: $multiPeerSession, tempHideTime: multiPeerSession.room.hideTime, tempSeekTime: multiPeerSession.room.seekTime, tempFakeRock: multiPeerSession.room.fakeRock, tempRealRock: multiPeerSession.room.realRock)
            })
            .onAppear{
                multiPeerSession.createRoom()
                multiPeerSession.room.teams[0].players.append(myself)
            }
        }
//        .onChange(of: multiPeerSession.connectedPeers) { peers in
//            print("connected berubah")
//            let allPlayers = room.teams[0].players + room.teams[1].players
//            
//        }
//        .onAppear(perform: {
//            self.roomVM = RoomViewModel(room: $room, multipeerSession: $multiPeerSession)
//        })
    }
}

//#Preview {
//    RoomView()
//}

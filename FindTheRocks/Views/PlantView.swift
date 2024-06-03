//
//  PlantView.swift
//  FindTheRocks
//
//  Created by Sidi Praptama Aurelius Nurhalim on 31/05/24.
//

import UIKit
import SwiftUI
import SceneKit
import ARKit
import MultipeerConnectivity

struct PlantView: View {
//    @Binding var room: Room
    @State var selectedButton = "real"
    @State var teamName = ""
    @Binding var multiPeerSession: MultipeerSession
    @Binding var room: Room
    
    func getMyTeam() {
        let redTeamplayers = room.teams[0].players.map { $0.peerID }
        let blueTeamPlayers = room.teams[1].players.map { $0.peerID }
        
        
        if redTeamplayers.contains(multiPeerSession.peerID) {
            teamName = "red"
        }
        else if redTeamplayers.contains(multiPeerSession.peerID) {
            teamName = "blue"
        }
        else {
            teamName = "none"
        }
        
        print("label: \(teamName)")
    }
    
    var body: some View {
        NavigationStack(){
            GeometryReader { gp in
                VStack(alignment: .leading) {
                    HStack {
                        VStack {
                            Text("05:00")
                                .font(.custom("TitanOne", size: 30))
                                .foregroundColor(Color.white)
                        }
                        SkewedRoundedRectangle(topLeftYOffset: -2, topRightXOffset: -2, topRightYOffset: -0.5, bottomLeftXOffset: 2, cornerRadius: 10)
                            .frame(height: 40)
                            .foregroundStyle(teamName == "red" ? Color.redGradient : teamName == "blue" ? Color.blueGradient : Color.whiteGradient)
                            .overlay(
                                Text("Blue Team Planting")
                                    .font(.custom("TitanOne", size: 18))
                                    .foregroundColor(teamName == "none" ? Color(hex: "CB9FF9") : Color.white)
                                    .fontWeight(.bold)
                            )
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                    }
                    ARControllerRepresentable()
                        .background(Color.white)
                        .cornerRadius(15)
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
                        .background(selectedButton == "real" ? Color.tersierGradient.opacity(1) : Color.whiteGradient.opacity(0.2))
                        .cornerRadius(15)
                        .onTapGesture {
                            selectedButton = "real"
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
                        .background(selectedButton == "fake" ? Color.tersierGradient.opacity(1) : Color.whiteGradient.opacity(0.2))
                        .cornerRadius(15)
                        .onTapGesture {
                            selectedButton = "fake"
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal,20)
                .padding(.vertical,0)
            }
            .background(Color.primaryGradient)
            .onAppear {
                self.getMyTeam()
            }
        }
    }
}

struct ARControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ARController {
        // Return an instance of your ARController
        return ARController()
    }

    func updateUIViewController(_ uiViewController: ARController, context: Context) {
        // Update the view controller if needed
    }
}

//#Preview {
//    PlantView()
//}

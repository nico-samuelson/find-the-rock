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
    @State var selectedButton = "real"
    @State var myTeam = -1
    @Binding var multiPeerSession: MultipeerSession
    
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
                            .foregroundStyle(myTeam == 0 ? Color.redGradient : myTeam == 1 ? Color.blueGradient : Color.whiteGradient)
                            .overlay(
                                Text(myTeam == 0 ? "Red Team Planting" : "Blue Team Planting")
                                    .font(.custom("TitanOne", size: 18))
                                    .foregroundColor(myTeam == -1 ? Color(hex: "CB9FF9") : Color.white)
                                    .fontWeight(.bold)
                            )
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                    }
                    ARControllerRepresentable(multipeerSession: $multiPeerSession)
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
                        .background(!multiPeerSession.isPlantingFakeRock ? Color.tersierGradient.opacity(1) : Color.whiteGradient.opacity(0.2))
                        .cornerRadius(15)
                        .onTapGesture {
                            multiPeerSession.isPlantingFakeRock = false
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
                        .background(multiPeerSession.isPlantingFakeRock ? Color.tersierGradient.opacity(1) : Color.whiteGradient.opacity(0.2))
                        .cornerRadius(15)
                        .onTapGesture {
                            multiPeerSession.isPlantingFakeRock = true
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal,20)
                .padding(.vertical,0)
            }
            .background(Color.primaryGradient)
            .onAppear {
                myTeam = multiPeerSession.getTeam(multiPeerSession.peerID)
            }
        }
    }
}



//#Preview {
//    PlantView()
//}
//#Preview {
//    PlantView()
//}

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

struct InGameView: View {
//    @Binding var room: Room
    @State var redPoints: Int = 0
    @State var bluePoints: Int = 0
    @Binding var multiPeerSession: MultipeerSession
    @Binding var room: Room
    
    func updatePoint() {
        redPoints = room.teams[0].players.reduce(0) { $0 + $1.point }
        bluePoints = room.teams[1].players.reduce(0) { $0 + $1.point }
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
                                Text("\(redPoints)")
                                    .font(.custom("TitanOne", size: 40))
                                    .foregroundColor(Color.white)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.redGradient)
                            .cornerRadius(15, corners: [.topLeft])
                            VStack {
                                Text("\(bluePoints)")
                                    .font(.custom("TitanOne", size: 40))
                                    .foregroundColor(Color.white)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.blueGradient)
                            .cornerRadius(15, corners: [.topRight])
                        }
                        ARControllerRepresentable()
                            .background(Color.white)
                            .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
                            .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal,20)
                .padding(.vertical,0)
            }
            .background(Color.primaryGradient)
        }
    }
}

//#Preview {
//    InGameView()
//}

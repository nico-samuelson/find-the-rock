//
//  WaitingScreenComponent.swift
//  FindTheRocks
//
//  Created by Sidi Praptama Aurelius Nurhalim on 08/06/24.
//

import SwiftUI
import SceneKit

struct WaitingPlantScreenView: View {
    @Binding var planterTeam : Int
    @Binding var timeRemaining : Int
    var scene : SCNScene = loadScene(named: "art.scnassets/models/rock-home.scn")
    
    func format(seconds: Int) -> String {
        String(format:"%d:%02d", seconds / 60, seconds % 60)
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { gp in
                VStack {
                    HStack {
                        Spacer()
                        Text("\(format(seconds: timeRemaining))")
                            .font(.custom("Staatliches-Regular", size: 21))
                            .foregroundStyle(Color.white)
                            .frame(width: 60, height: 60, alignment: .center)
                            .overlay {
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .fill(.clear)
                                    .frame(width: 60, height: 60)
                            }
                            .padding(10)
                            .padding(.horizontal, 10)
                    }
                    Spacer()
                    VStack(alignment: .center) {
                        Spacer()
                        LegacySceneView(scene: self.scene)
                        SkewedRoundedRectangle(topLeftYOffset: -2, topRightXOffset: 5, topRightYOffset: 1, bottomLeftXOffset: -2, cornerRadius: 15)
                            .frame(height: 60)
                            .padding(.horizontal, 50)
                            .foregroundStyle(planterTeam == 0 ? Color.blueGradient : Color.redGradient)
                            .overlay {
                                Text(planterTeam == 0 ? "Blue Team Planting" : "Red Team Planting")
                                    .foregroundStyle(.white)
                                    .fontWeight(.bold)
                                    .font(.custom("Staatliches-Regular", size: 32))
                            }
                            .offset(y: -50)
                    }
                    .frame(height: gp.size.height / 2)
                    .offset(y: -70)
                    Spacer()
                }
                .background(Color.secondaryGradient)
            }
        }
    }
}

//#Preview {
//    @State var waitingTeamNeam = "Red Team"
    
//    WaitingScreenComponent(waitingTeamName: $waitingTeamNeam)
//}

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
//    @State var team = ['red', 'blue']
    
    var body: some View {
        NavigationStack(){
            GeometryReader { gp in
                VStack(alignment: .leading) {
                    HStack {
                        SkewedRoundedRectangle(topLeftYOffset: -2, topRightXOffset: 5, topRightYOffset: 1, bottomLeftXOffset: -2, cornerRadius: 15)
                            .frame(height: 60)
                            .padding(.horizontal, 90)
                            .padding(.vertical, 30)
//                            .foregroundStyle(winner == "DRAW" ? Color.tersierGradient : winner == "RED TEAM" ? Color.redGradient : Color.blueGradient)
//                            .overlay(
//                                Text(winner)
//                                    .foregroundStyle(.white)
//                                    .fontWeight(.bold)
//                                    .font(.system(size: 32))
//                            )
                    }
                    ARControllerRepresentable()
                }
                .padding(.horizontal,20)
                .padding(.vertical,0)
            }.background(Color.primaryGradient)
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

#Preview {
    PlantView()
}

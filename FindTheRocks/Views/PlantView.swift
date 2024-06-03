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
    @Binding var multiPeerSession: MultipeerSession
    
    var body: some View {
        NavigationStack(){
            GeometryReader { gp in
                VStack(alignment: .leading) {
                    HStack {
                        SkewedRoundedRectangle(topLeftYOffset: -2, topRightXOffset: 5, topRightYOffset: 1, bottomLeftXOffset: -2, cornerRadius: 15)
                            .frame(height: 60)
                            .padding(.horizontal, 90)
                            .padding(.vertical, 30)
                            .foregroundStyle(Color.redGradient)
                            .overlay(
                                Text("RED TEAM")
                                    .foregroundStyle(.white)
                                    .fontWeight(.bold)
                                    .font(.system(size: 32))
                            )
                    }
                    ARControllerRepresentable(multipeerSession: $multiPeerSession)
                }
                .padding(.horizontal,20)
                .padding(.vertical,0)
            }
            .background(Color.primaryGradient)
//            .onChange(of: multiPeerSession.newAnchor, perform: { anchor in
//                print("on change anchor:", anchor)
//            })
        }
    }
}

struct ARControllerRepresentable: UIViewControllerRepresentable {
    @Binding var multipeerSession: MultipeerSession
    
    func makeUIViewController(context: Context) -> ARController {
        // Return an instance of your ARController
        return ARController(multipeerSession: multipeerSession)
    }

    func updateUIViewController(_ uiViewController: ARController, context: Context) {
        // Update the view controller if needed
    }
}

//#Preview {
//    PlantView()
//}

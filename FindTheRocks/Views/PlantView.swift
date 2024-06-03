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
    
    
    var body: some View {
        NavigationStack(){
            GeometryReader { gp in
                VStack(alignment: .leading) {
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

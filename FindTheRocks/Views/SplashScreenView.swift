//
//  SplashScreenView.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 06/06/24.
//

import SwiftUI

struct SplashScreenView: View {
    @Environment(AudioObservable.self) var audio
    @State private var offsetY: CGFloat = -800
    
    var body: some View {
        GeometryReader { gp in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Image("AppIcon-nobg")
                            .resizable()
                            .frame(width: 350, height: 350)
                            .foregroundStyle(.white)
                            .offset(y: offsetY)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    withAnimation(.spring(dampingFraction: 0.9)) {
                                        audio.playDrop()
                                        offsetY = 0
                                    }
                                }
                            }
                    }
                    Spacer()
                }
                Spacer()
            }
            .frame(minWidth: gp.size.width, minHeight: gp.size.height)
            .background(Color.iconGradient)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

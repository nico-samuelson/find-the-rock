//
//  HomeView.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 28/05/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack() {
            GeometryReader { gp in
                //                VStack(alignment:.leading,spacing:0){
                VStack{
                    Text("Find")
                        .font(.title)
                        .foregroundStyle(.white)
                        .bold()
                        .padding(.top,40)
                    Text("ThE ROCK")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .bold()
                }
                .frame(minWidth:gp.size.width,minHeight:gp.size.height/30*7)
                .background{
                    SkewedRoundedRectangle(bottomRightYOffset: 20,cornerRadius: 30)
                        .fill(Color.primaryGradient)
                        .shadow(color:.init(.black.opacity(0.25)),radius: 20,x:0,y:4)
                    //                            .overlay(
                    //                                SkewedRoundedRectangle(bottomRightYOffset: 20,cornerRadius: 30)
                    //                                    .shadow(radius: 10)
                    //                            )
                }
                //                }
            }
            .background(Color.secondaryGradient)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    HomeView()
}

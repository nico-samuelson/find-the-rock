//
//  SplashScreenView.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 06/06/24.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var offsetY:CGFloat = 0
    var body: some View {
        GeometryReader{gp in
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    VStack{
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width:100,height:100)
                            .foregroundStyle(.white)
                        Text("Find ThE ROCK")
                            .font(.custom("TitanOne",size:30))
                            .bold()
                            .foregroundStyle(.white)
                    }.offset(x:0,y:0 - offsetY)
                    Spacer()
                }
                Spacer()
            }
            .frame(minWidth: gp.size.width,minHeight: gp.size.height)
            .background(Color.secondaryGradient)
            .edgesIgnoringSafeArea(.all)
            .onAppear(){
                DispatchQueue.main.asyncAfter(deadline:.now() + 0.8){
                    withAnimation(.easeOut(duration:0.5)){
                        offsetY = gp.size.height
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}

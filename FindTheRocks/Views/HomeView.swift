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
                VStack(alignment:.center,spacing:0){
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
                    }
                    Spacer()
                    Image(systemName: "magnifyingglass.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:gp.size.width/2)
                    Spacer()
                    
                    VStack(){
                        Image("lancelot-avatar")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .frame(width:75,height:75)
                            .background{
                                Circle()
                                    .fill(.white.opacity(0.2))
                                    .frame(width:85,height:85)
                            }
                            .padding(.top,-35)
                            
                        Spacer()
                            .frame(height:25)
                        
                        
                        HStack(alignment:.center,spacing:0){
                            VStack{
                                Spacer()
                                    .frame(height:10)
                                Text("Nico Samuel")
                                    .font(.title)
                                    .foregroundStyle(.white)
                                    .bold()
                                    .padding(.horizontal,28)
                                Spacer()
                                    .frame(height:10)
                            }
                            .background(){
                                Rectangle()
                                    .fill(.white.opacity(0.2))
                            }
                            VStack{
                                Spacer()
                                    .frame(height:12)
                                Image(systemName: "pencil")
                                    .foregroundStyle(.white)
                                    .font(.title)
                                    .bold()
                                    .padding(.horizontal,16)
                                Spacer()
                                    .frame(height:12)
                            }
                            .background(){
                                Rectangle()
                                    .fill(Color.white.opacity(0.5))
                            }
                        }
                        .clipShape(SkewedRoundedRectangle(topLeftXOffset: 2,topRightXOffset: 2,bottomRightYOffset: 0.56, cornerRadius: 20))
                        Spacer()
                            .frame(height:12)
                        Text("CREATE ROOM")
                            .font(.title)
                            .foregroundStyle(.white)
                            .bold()
                            .padding(20)
                            .padding(.horizontal,24)
                            .background(){
                                SkewedRoundedRectangle(topLeftYOffset: 5,bottomRightXOffset: 5,bottomLeftXOffset: 5,cornerRadius: 20)
                                    .fill(Color.tersierGradient)
                            }
                        Spacer()
                    }.frame(width:gp.size.width,height:gp.size.height/30*9)
                    .background(){
                        CustomRandomShape()
                            .fill(Color.primaryGradient)
                            .shadow(color:.init(.black.opacity(0.33)),radius: 20,x:0,y:4)
                    }
                }
            }
            .background(Color.secondaryGradient)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    HomeView()
}

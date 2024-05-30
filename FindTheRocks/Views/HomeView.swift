//
//  HomeView.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 28/05/24.
//

import SwiftUI

struct HomeView: View {
    @State private var name: String = "Nico Samuel"
    @Binding var multiPeerSession: MultipeerSession
    var body: some View {
        NavigationStack() {
            GeometryReader { gp in
                VStack(alignment:.center,spacing:0){
                    VStack{
                        Text("Find")
                            .font(.custom("Roboto", size:40))
                            .foregroundStyle(.white)
                            .padding(.top,40)
                            .rotationEffect(.degrees(-3))
                        Text("ThE ROCK")
                            .font(.custom("Roboto",size:40))
                            .foregroundStyle(.white)
                            .bold()
                            .rotationEffect(.degrees(-3))
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
                            TextField("", text: $name)
                                .font(.custom("Roboto", size: 27, relativeTo: .title))
                                .foregroundColor(.white)
                                .padding(.leading,30)
                                .frame(maxWidth:225,maxHeight:60)
                                .background(){
                                    Rectangle()
                                        .fill(.white.opacity(0.2))
                                }
                            Image(systemName: "pencil")
                                .foregroundStyle(.white)
                                .font(.title)
                                .bold()
                                .frame(width:55,height:60)
                                .background(){
                                    Rectangle()
                                        .fill(Color.white.opacity(0.5))
                                }
                                .onTapGesture {
                                    multiPeerSession.updateDisplayName(name)
                                }
                        }
                        .clipShape(SkewedRoundedRectangle(topLeftXOffset: 2,topRightXOffset: 2,bottomRightYOffset: 4, cornerRadius: 20))
                        Spacer()
                            .frame(height:12)
                        Text("CREATE ROOM")
                            .font(.custom("Roboto",size:28,relativeTo: .title))
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

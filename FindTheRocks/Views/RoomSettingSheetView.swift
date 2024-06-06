//
//  RoomSettingSheetView.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 29/05/24.
//

import SwiftUI

struct RoomSettingSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var multiPeerSession: MultipeerSession
    @State var tempHideTime: Int
    @State var tempSeekTime: Int
    @State var tempFakeRock: Int
    @State var tempRealRock: Int
    
    var body: some View {
        let hides = [5, 10, 15]
        let seeks = [5, 10, 15, 0]
        
        NavigationStack(){
            GeometryReader{gp in
                VStack(alignment:.leading){
                    Text("Room Setting")
                        .font(.custom("TitanOne",size:38))
                        .foregroundStyle(.white)
                    Spacer()
                        .frame(height:16)
//                    Duration Settings
                    Text("Duration")
                        .font(.custom("TitanOne",size:22))
                        .foregroundStyle(.white)
                        .padding(.leading,16)
                    Spacer()
                        .frame(height:8)
                    VStack(alignment:.leading){
                        Text("Hide")
                            .font(.custom("TitanOne",size:18))
                            .foregroundStyle(.white)
                            .padding(.leading,8)
                        Spacer()
                            .frame(height:8)
                        HStack{
                            ForEach(hides, id: \.self){element in
                                Spacer()
                                ButtonPillComponent(value: element ,padding:16, activeController: $multiPeerSession.room.hideTime)
                            }
                        }.padding(.trailing,4)
                        Text("Seek")
                            .font(.custom("TitanOne",size:18))
                            .foregroundStyle(.white)
                            .padding(.leading,8)
                        Spacer()
                            .frame(height:8)
                        HStack{
                            ForEach(seeks, id: \.self){element in
                                Spacer()
                                ButtonPillComponent(value: element ,padding:5, activeController: $multiPeerSession.room.seekTime)
                            }
                        }.padding(.trailing,4)
                    }
                    .padding(.horizontal,10)
                    .frame(width:gp.size.width-40,height:200)
                    .background{
                        SkewedRoundedRectangle(topLeftXOffset:2,topRightYOffset:2,bottomRightXOffset:2,bottomRightYOffset:1,cornerRadius:20)
                            .fill(.white.opacity(0.25))
                    }
                    Spacer()
                        .frame(height:24)
                    //                    Rock Settings
                    Text("Rock(s)")
                        .font(.custom("TitanOne",size:22))
                        .foregroundStyle(.white)
                        .padding(.leading,16)
                    Spacer()
                        .frame(height:8)
                    VStack(alignment:.leading){
                        Text("Fake")
                            .font(.custom("TitanOne",size:18))
                            .foregroundStyle(.white)
                            .padding(.leading,24)
                        Spacer()
                            .frame(height:8)
                        CustomStepperComponent(value:$multiPeerSession.room.fakeRock)
                        Text("Real")
                            .font(.custom("TitanOne",size:18))
                            .foregroundStyle(.white)
                            .padding(.leading,24)
                        Spacer()
                            .frame(height:8)
                        CustomStepperComponent(value:$multiPeerSession.room.realRock)
                    }
                    .frame(width:gp.size.width-40,height:200)
                    .background{
                        SkewedRoundedRectangle(topLeftXOffset:2,topRightYOffset:2,bottomRightXOffset:2,bottomRightYOffset:1,cornerRadius:20)
                            .fill(.white.opacity(0.25))
                    }
                    Spacer()
                    VStack(alignment:.center,spacing:16){
                        Text("Reset")
                            .font(.custom("Staatliches-Regular",size:36,relativeTo: .title))
                            .foregroundStyle(Color.init(red: 142/255.0,green:111/255.0,blue:255/255.0))
                            .bold()
                            .frame(width:gp.size.width-120,height:70)
                            .background(){
                                SkewedRoundedRectangle(topLeftYOffset: 5,topRightXOffset:5,cornerRadius: 20)
                                    .fill(Color.white)
                            }
                            .onTapGesture {
                                multiPeerSession.room.hideTime = tempHideTime
                                multiPeerSession.room.seekTime = tempSeekTime
                                multiPeerSession.room.fakeRock = tempFakeRock
                                multiPeerSession.room.realRock = tempRealRock
                                dismiss()
                            }
                        Text("Apply")
                            .font(.custom("Staatliches-Regular",size:36,relativeTo: .title))
                            .foregroundStyle(.white)
                            .bold()
                            .frame(width:gp.size.width-100,height:75)
                            .background(){
                                SkewedRoundedRectangle(topLeftYOffset: 5,bottomRightXOffset: 5,bottomLeftXOffset: 5,cornerRadius: 20)
                                    .fill(Color.tersierGradient)
                            }
                            .onTapGesture {
                                multiPeerSession.syncRoom()
                                dismiss()
                            }
                    }
                    .frame(width:gp.size.width-40)
                }
                .padding(.horizontal,20)
                .padding(.vertical,0)
            }.background(Color.primaryGradient)
        }
//        .gesture(DragGesture(minimumDistance: 1, coordinateSpace: .local)
//            .onEnded({ value in
//                if value.translation.height > 1 {
//                    isSettingActive.toggle()
//                }
//            }))
    }
}

//#Preview {
//    RoomSettingSheetView()
//}

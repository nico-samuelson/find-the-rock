//
//  ButtonPillComponent.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 29/05/24.
//

import SwiftUI

struct ButtonPillComponent: View {
    @Environment(AudioObservable.self) var audio
    var value:Int
    var padding:CGFloat
    @Binding var activeController:Int
    var body: some View {
        Text(value == 0 ? "∞" : "\(value) MIN")
            .font(.custom("Staatliches-Regular",size:22))
            .foregroundStyle(activeController == value ? .white : .init(red:142/255.0,green:111/255.0,blue:255/255.0))
            .bold()
            .padding(10)
            .padding(.horizontal,padding)
            .background(){
                if activeController == value {
                    SkewedRoundedRectangle(topLeftXOffset: 0.1, topRightYOffset:0.2, bottomRightYOffset: 0.5, cornerRadius: 20)
                        .fill(Color.tersierGradient)
                }else{
                    SkewedRoundedRectangle(topLeftXOffset: 0.1, topRightYOffset:0.2, bottomRightYOffset: 0.5, cornerRadius: 20)
                        .fill(.white)
                }
            }
            .onTapGesture {
                audio.playClick()
                activeController = value
            }
    }
}

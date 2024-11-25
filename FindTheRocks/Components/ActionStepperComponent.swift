//
//  ActionStepperComponent.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 29/05/24.
//

import SwiftUI

struct ActionStepperComponent: View {
    @Environment(AudioObservable.self) var audio
    var action:String
    @Binding var value:Int
    var body: some View {
        Image(systemName: action)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.white)
            .frame(width:20,height:30)
            .padding(.horizontal,22)
            .padding(.vertical,4)
            .background{
                SkewedRoundedRectangle(bottomRightYOffset:1,cornerRadius: 20)
                    .fill(Color.tersierGradient)
            }
            .onTapGesture {
                audio.playClick()
                if action == "plus" {
                    guard value < 15 else {
                        return
                    }
                    value +=  1
                }
                if action == "minus" {
                    guard value > 1 else {
                        return
                    }
                    value -=  1
                }
            }
    }
}

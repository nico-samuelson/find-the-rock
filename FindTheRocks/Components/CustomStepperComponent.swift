//
//  CustomStepperComponent.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 29/05/24.
//

import SwiftUI

struct CustomStepperComponent: View {
    @Binding var value:Int
    var body: some View {
        HStack{
            ActionStepperComponent(action:"minus",value:$value)
            Spacer()
            Text("\(value) ROCKS")
                .font(.custom("Staatliches-Regular",size:20))
                .foregroundStyle(Color.init(red:142/255.0,green:111/255.0,blue:255/255.0))
                .bold()
                .frame(width:160,height:40)
                .background(){
                    SkewedRoundedRectangle(topLeftXOffset: 0.1, topRightYOffset:0.2, bottomRightYOffset: 0.5, cornerRadius: 20)
                        .fill(.white)
                }
                .onTapGesture {
                }
            Spacer()
            ActionStepperComponent(action:"plus",value:$value)
        }.padding(.horizontal,16)
    }
}

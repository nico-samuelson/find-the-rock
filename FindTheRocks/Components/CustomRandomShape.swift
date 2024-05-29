//
//  CustomRandomShape.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 28/05/24.
//

import SwiftUI

struct CustomRandomShape: Shape {
    var cornerRadius:CGFloat = 30
    var skewed:CGFloat = -5
    
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width:CGFloat = rect.width
        let height:CGFloat = rect.height
        
        path.move(to: CGPoint(x: 0, y: skewed + cornerRadius))
        
        path.addQuadCurve(to: CGPoint(x:cornerRadius,y:skewed), control: CGPoint(x:0,y:(skewed*1.1))
        )
        
        path.addLine(to: CGPoint(x:width-cornerRadius,y:0 - skewed))
        
        
        
        path.addQuadCurve(to: CGPoint(x:width,y:cornerRadius-skewed), control: CGPoint(x:width,y:0 - skewed*1.1)
        )
        path.addLine(to: CGPoint(x:width,y:height))
        path.addLine(to: CGPoint(x:0,y:height))
        path.addLine(to: CGPoint(x:0,y:cornerRadius + skewed))
        
//        Curve left
        path.move(to:CGPoint(x:width * 0.325,y:skewed * 0.262))
        path.addQuadCurve(to: CGPoint(x:width * 0.382,y: 0 - cornerRadius * 0.72), control: CGPoint(x:width * 0.367,y: 0 - cornerRadius*0.28))
        
        
        path.addArc(
            center: CGPoint(x: width / 2, y: skewed * 0.005),
            radius: cornerRadius * 1.7,
            startAngle: .degrees(180),
            endAngle: .degrees(50),
            clockwise: false
        )
        
//        curve right
        path.move(to:CGPoint(x:width * 0.619,y:0 - cornerRadius * 0.68))
        path.addQuadCurve(to: CGPoint(x:width * 0.7,y: 0 - skewed*0.48), control: CGPoint(x:width * 0.65,y:  cornerRadius*0.14))
        
        path.addArc(
            center: CGPoint(x: width / 2, y: skewed * 0.005),
            radius: cornerRadius * 1.7,
            startAngle: .degrees(180),
            endAngle: .degrees(50),
            clockwise: false
        )
        
        return path
    }
    
}

#Preview {
    CustomRandomShape()
        .padding(.top,600)
        .foregroundStyle(Color.primaryGradient)
        .ignoresSafeArea()
}

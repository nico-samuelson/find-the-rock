//
//  SkewedRoundedRectangle.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 28/05/24.
//

import SwiftUI

struct SkewedRoundedRectangle: Shape {
//    Top Left (positive is to inside)
    var topLeftXOffset:CGFloat = 0
    var topLeftYOffset:CGFloat = 0
    
//    Top Right (positive is to inside)
    var topRightXOffset:CGFloat = 0
    var topRightYOffset:CGFloat = 0
    
//    Bottom Right (positive is to inside)
    var bottomRightXOffset:CGFloat = 0
    var bottomRightYOffset:CGFloat = 0
    
//    Bottom Left (positive is to inside)
    var bottomLeftXOffset:CGFloat = 0
    var bottomLeftYOffset:CGFloat = 0
    
    var cornerRadius: CGFloat = 20
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Start at the top-left corner
        path.move(to: CGPoint(x: topLeftXOffset , y: cornerRadius))
        
        // Top-left rounded corner
        path.addArc(center: CGPoint(x: cornerRadius + topLeftXOffset, y: cornerRadius + topLeftYOffset), radius: cornerRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        
        // Top side
        path.addLine(to: CGPoint(x: width - cornerRadius - topRightXOffset, y: 0 + topRightYOffset))
        
        // Top-right rounded corner
        path.addArc(center: CGPoint(x: width - cornerRadius - topRightXOffset, y: cornerRadius + topRightYOffset), radius: cornerRadius, startAngle: .degrees(270), endAngle: .degrees(360), clockwise: false)
        
        // Right side skewed
        path.addLine(to: CGPoint(x: width - bottomRightXOffset, y: height - cornerRadius - bottomRightYOffset))
        
        // Bottom-right rounded corner
        path.addArc(center: CGPoint(x: width - cornerRadius - bottomRightXOffset, y: height - cornerRadius - bottomRightYOffset), radius: cornerRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        
        // Bottom side
        path.addLine(to: CGPoint(x: cornerRadius + bottomLeftXOffset, y: height - bottomLeftYOffset))
        
        // Bottom-left rounded corner
        path.addArc(center: CGPoint(x: cornerRadius + bottomLeftXOffset, y: height - cornerRadius - bottomLeftYOffset), radius: cornerRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        
        // Left side
        path.addLine(to: CGPoint(x: 0 + topLeftXOffset, y: cornerRadius + topLeftYOffset))
        
        return path
    }
}
#Preview {
    SkewedRoundedRectangle()
        .padding(100)
}

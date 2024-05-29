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
    
    var topLeftCornerRadius: CGFloat = 0
    var topRightCornerRadius: CGFloat = 0
    var bottomLeftCornerRadius: CGFloat = 0
    var bottomRightCornerRadius: CGFloat = 0
    
    var cornerRadius: CGFloat? = nil
    
    func path(in rect: CGRect) -> Path {
        let tlCornerRadius = cornerRadius ?? topLeftCornerRadius
        let trCornerRadius = cornerRadius ?? topRightCornerRadius
        let blCornerRadius = cornerRadius ?? bottomLeftCornerRadius
        let brCornerRadius = cornerRadius ?? bottomRightCornerRadius
        
        var path = Path()
        
        let width:CGFloat = rect.width
        let height:CGFloat = rect.height
        
        // Start at the top-left corner
        path.move(to: CGPoint(x: topLeftXOffset , y: tlCornerRadius + topLeftYOffset))
        
        // Top-left rounded corner
//        path.addArc(center: CGPoint(x: cornerRadius + topLeftXOffset, y: cornerRadius + topLeftYOffset), radius: cornerRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.addQuadCurve(
            to: CGPoint(x: topLeftXOffset + tlCornerRadius, y: topLeftYOffset),
            control: CGPoint(x: topLeftXOffset + (topLeftXOffset - bottomLeftXOffset)*0.08, y: topLeftYOffset + (topLeftYOffset - topRightYOffset)*0.15)
        )
        
        
        // Top side
        path.addLine(to: CGPoint(x: width - trCornerRadius - topRightXOffset, y: topRightYOffset))
        
        // Top-right rounded corner
//        path.addArc(center: CGPoint(x: width - cornerRadius - topRightXOffset, y: cornerRadius + topRightYOffset), radius: cornerRadius, startAngle: .degrees(270), endAngle: .degrees(360), clockwise: false)
        path.addQuadCurve(
            to: CGPoint(x: width - topRightXOffset, y: topRightYOffset + trCornerRadius),
            control: CGPoint(x: width - topRightXOffset - (topRightXOffset - bottomRightXOffset)*0.08, y: topRightYOffset + (topRightYOffset - topLeftYOffset)*0.15)
        )
        
        
        // Right side skewed
        path.addLine(to: CGPoint(x: width - bottomRightXOffset, y: height - brCornerRadius - bottomRightYOffset))
        
        // Bottom-right rounded corner
//        path.addArc(center: CGPoint(x: width - cornerRadius - bottomRightXOffset, y: height - cornerRadius - bottomRightYOffset), radius: cornerRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addQuadCurve(
            to: CGPoint(x: width - brCornerRadius - bottomRightXOffset, y: height - bottomRightYOffset),
            control: CGPoint(x: width - bottomRightXOffset - (bottomRightXOffset - bottomLeftXOffset)*0.08, y: height - bottomRightYOffset - (bottomRightYOffset - topRightYOffset)*0.15)
        )
        
        // Bottom side
        path.addLine(to: CGPoint(x: blCornerRadius + bottomLeftXOffset, y: height - bottomLeftYOffset))
        
        // Bottom-left rounded corner
//        path.addArc(center: CGPoint(x: cornerRadius + bottomLeftXOffset, y: height - cornerRadius - bottomLeftYOffset), radius: cornerRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addQuadCurve(
            to: CGPoint(x: bottomLeftXOffset, y: height - blCornerRadius - bottomLeftYOffset),
            control: CGPoint(x: bottomLeftXOffset + (bottomLeftXOffset - topLeftXOffset)*0.08, y: height - bottomLeftYOffset - (bottomLeftYOffset - bottomRightYOffset)*0.15)
        )
        
        // Left side
        path.addLine(to: CGPoint(x: 0 + topLeftXOffset, y: tlCornerRadius + topLeftYOffset))
        
        return path
    }
}
#Preview {
    SkewedRoundedRectangle(cornerRadius:20)
        .padding(100)
}

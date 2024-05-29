//
//  IrregularButton.swift
//  FindTheRocks
//
//  Created by Nico Samuelson on 28/05/24.
//

import Foundation
import SwiftUI

struct IrregularShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Define the points for your custom shape here
        // Example for a triangle shape:
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addArc(center: <#T##CGPoint#>, radius: <#T##CGFloat#>, startAngle: <#T##Angle#>, endAngle: <#T##Angle#>, clockwise: <#T##Bool#>)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}


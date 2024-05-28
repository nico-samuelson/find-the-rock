//
//  Color.swift
//  FindTheRocks
//
//  Created by Nico Samuelson on 28/05/24.
//

import Foundation
import SwiftUI

public extension Color {
    static let primaryGradient: LinearGradient = LinearGradient(
        stops: [
            .init(color: .init(red: 233/255.0, green: 168/255.0, blue: 255/255.0), location: 0),
            .init(color: .init(red: 185/255.0, green: 97/255.0, blue: 255/255.0), location: 0.3),
            .init(color: .init(red: 109/255.0, green: 71/255.0, blue: 253/255.0), location: 1),
        ], startPoint: .init(x: 0.2, y: -0.2), endPoint: .init(x: 0.7, y: 1.2))
    
    static let secondaryGradient: RadialGradient = RadialGradient(colors: [
        .init(red: 255/255.0, green: 225/255.0, blue: 130/255.0), 
        .init(red: 255/255.0, green: 82/255.0, blue: 225/255.0)
    ], center: .center, startRadius: 5, endRadius: 450)
}

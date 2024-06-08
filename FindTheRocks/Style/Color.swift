//
//  Color.swift
//  FindTheRocks
//
//  Created by Nico Samuelson on 28/05/24.
//

import Foundation
import SwiftUI

public extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
    
    static let primaryGradient: LinearGradient = LinearGradient(
        stops: [
            .init(color: .init(red: 233/255.0, green: 168/255.0, blue: 255/255.0), location: 0),
            .init(color: .init(red: 185/255.0, green: 97/255.0, blue: 255/255.0), location: 0.3),
            .init(color: .init(red: 109/255.0, green: 71/255.0, blue: 253/255.0), location: 1),
        ], startPoint: .init(x: 0.2, y: -0.2), endPoint: .init(x: 0.7, y: 1.2))
    
    static let iconGradient: RadialGradient = RadialGradient(colors: [
        .init(red: 255/255.0, green: 129/255.0, blue: 241/255.0), // Placeholder for inner light blue
            .init(red: 178/255.0, green: 87/255.0, blue: 233/255.0),
        .init(red: 97/255.0, green: 0/255.0, blue: 253/255.0), // Placeholder for outer purple
    ], center: .center, startRadius: 5, endRadius: UIScreen.main.bounds.width)
    
    static let secondaryGradient: RadialGradient = RadialGradient(colors: [
        .init(red: 255/255.0, green: 225/255.0, blue: 130/255.0),
            .init(red: 255/255.0, green: 82/255.0, blue: 225/255.0)
    ], center: .center, startRadius: 5, endRadius: 450)
    
    static let tersierGradient: LinearGradient = LinearGradient(
        stops: [
            .init(color: .init(red: 249/255.0, green: 164/255.0, blue: 49/255.0), location: 0),
            .init(color: .init(red: 225/255.0, green: 181/255.0, blue: 71/255.0), location: 0.5),
            .init(color: .init(red: 225/255.0, green: 200/255.0, blue: 118/255.0), location: 1),
        ], startPoint: .init(x: 0.6, y: -0.1), endPoint: .init(x: 0.2, y: 1.9))
    
    static let primaryPurple: LinearGradient = LinearGradient(colors: [.init(red: 142/255.0, green: 111/255.0, blue: 255/255.0), .init(red: 142/255.0, green: 111/255.0, blue: 255/255.0)], startPoint: .leading, endPoint: .trailing)
    
    static let redGradient: LinearGradient = LinearGradient(
        stops: [
            .init(color: .init(red: 219/255.0, green: 83/255.0, blue: 69/255.0), location: 0),
            .init(color: .init(red: 240/255.0, green: 157/255.0, blue: 149/255.0), location: 1),
        ], startPoint: .init(x: 0.5, y: -0.05), endPoint: .init(x: 0.5, y: 1))
    
    static let blueGradient: LinearGradient = LinearGradient(
        stops: [
            .init(color: .init(red: 105/255.0, green: 172/255.0, blue: 232/255.0), location: 0),
            .init(color: .init(red: 140/255.0, green: 213/255.0, blue: 249/255.0), location: 1),
        ], startPoint: .init(x: 0.4, y: 0), endPoint: .init(x: 0.4, y: 1.2))
    
    static let lightBlue: Color = Color.init(red: 106/255.0, green: 173/255.0, blue: 233/255.0)
    
    static let lightRed: Color = Color.init(red: 224/255.0, green: 100/255.0, blue: 87/255.0)
    
    static let whiteGradient: LinearGradient = LinearGradient(
        stops: [
            .init(color: .init(red: 255/255.0, green: 255/255.0, blue: 255/255.0), location: 0),
            .init(color: .init(red: 225/255.0, green: 255/255.0, blue: 250/255.0), location: 1),
        ], startPoint: .init(x: 0.6, y: -0.1), endPoint: .init(x: 0.2, y: 1.9))
}

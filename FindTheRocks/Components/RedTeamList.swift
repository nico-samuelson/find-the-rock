//
//  RedTeamList.swift
//  FindTheRocks
//
//  Created by Nico Samuelson on 01/06/24.
//

import SwiftUI

struct RedTeamList: View {
    @Binding var players: [Player]
    
    var body: some View {
        List {
            ForEach(players, id: \.peerID) { player in
                HStack(alignment: .center) {
                    Circle()
                        .foregroundStyle(Color.lightRed)
                        .frame(width: 25, height: 25)
                        .overlay {
                            Circle()
                                .foregroundStyle(.white)
                                .padding(2)
                        }
                    
                    Text(player.peerID.displayName.uppercased())
                        .font(.system(size: 12))
                        .fontWeight(.medium)
                        .lineLimit(0)
                        .truncationMode(.tail)
                        .rotationEffect(.degrees(-0.48))
                    
                    Button{
                        kickPlayer(player: player)
                    } label: {
                        SkewedRoundedRectangle(topRightYOffset: 0.5, bottomRightYOffset: -0.5, bottomLeftXOffset: 0.5,
                                               topLeftCornerRadius: 10,
                                               topRightCornerRadius: 10,
                                               bottomLeftCornerRadius: 10,
                                               bottomRightCornerRadius: 10)
                        .foregroundStyle(.white)
                        .overlay(
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 10, height: 10)
                                .foregroundStyle(Color.primaryGradient)
                        )
                    }
                    .padding(0)
                    .frame(maxWidth: 25, maxHeight: 25)
                    
                    Button{
                        assignToTeam(player: player, to: 1)
                    } label: {
                        SkewedRoundedRectangle(topRightYOffset: 0.5, bottomRightYOffset: -0.5, bottomLeftXOffset: 0.5,
                                               topLeftCornerRadius: 10,
                                               topRightCornerRadius: 10,
                                               bottomLeftCornerRadius: 10,
                                               bottomRightCornerRadius: 10)
                        .foregroundStyle(Color.tersierGradient)
                        .overlay(
                            Image(systemName: "chevron.right")
                                .resizable()
                                .frame(width: 7.5, height: 13.5)
                                .foregroundStyle(.white)
                        )
                    }
                    .padding(0)
                    .frame(maxWidth: 25, maxHeight: 25)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(.none)
                .listRowSeparator(.hidden)
            }
        }
    }
    .padding(.horizontal, -10)
    .padding(.bottom, 10)
    .listStyle(.plain)
    .listRowSpacing(-6)
    .scrollDisabled(false)
    .scrollContentBackground(.hidden)
    .scrollIndicators(.visible)
    .background(
        SkewedRoundedRectangle(topRightYOffset: -5, bottomRightXOffset: -5, topLeftCornerRadius: 20, topRightCornerRadius: 20, bottomRightCornerRadius: 20)
            .foregroundStyle(.white.opacity(0.2))
    )
    
    VStack(spacing: 0) {
        SkewedRoundedRectangle(topLeftXOffset: 3.2, topLeftYOffset: -5, topRightYOffset: -10, bottomRightYOffset: 5, bottomLeftXOffset: 4.5, topLeftCornerRadius: 20)
            .frame(height: 55)
            .foregroundStyle(Color.blueGradient)
            .overlay(
                Text("BLUE TEAM")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .font(.system(size: 24))
                    .rotationEffect(.degrees(-2))
                    .offset(x: 2, y: -2)
            )
        
        List {
            ForEach(room.teams[1].players, id: \.peerID) { player in
                HStack(alignment: .center) {
                    Button{
                        assignToTeam(player: player, to: 0)
                    } label: {
                        SkewedRoundedRectangle(topRightYOffset: 0.5, bottomRightYOffset: -0.5, bottomLeftXOffset: 0.5, cornerRadius: 10)
                        .foregroundStyle(Color.tersierGradient)
                        .overlay(
                            Image(systemName: "chevron.left")
                                .resizable()
                                .frame(width: 7.5, height: 13.5)
                                .foregroundStyle(.white)
                        )
                    }
                    .padding(0)
                    .frame(maxWidth: 25, maxHeight: 25)
                    
                    Button{
                        kickPlayer(player: player)
                    } label: {
                        SkewedRoundedRectangle(topRightYOffset: 0.5, bottomRightYOffset: -0.5, bottomLeftXOffset: 0.5, cornerRadius: 10)
                        .foregroundStyle(.white)
                        .overlay(
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 10, height: 10)
                                .foregroundStyle(Color.primaryGradient)
                        )
                    }
                    .padding(0)
                    .frame(maxWidth: 25, maxHeight: 25)
                    
                    Text(player.peerID.displayName.uppercased())
                        .font(.system(size: 12))
                        .fontWeight(.medium)
                        .lineLimit(0)
                        .truncationMode(.tail)
                        .rotationEffect(.degrees(-0.48))
                    
                    Circle()
                        .foregroundStyle(Color.lightBlue)
                        .frame(width: 25, height: 25)
                        .overlay {
                            Circle()
                                .foregroundStyle(.white)
                                .padding(2)
                        }
                }
                .padding(0)
                .listRowBackground(Color.clear)
                .listRowInsets(.none)
                .listRowSeparator(.hidden)
            }
        }
    }
    .padding(.horizontal, -8)
    .padding(.bottom, 10)
    .listStyle(.plain)
    .listRowSpacing(-6)
    .scrollDisabled(false)
    .scrollContentBackground(.hidden)
    .scrollIndicators(.visible)
    .background(
        SkewedRoundedRectangle(topLeftXOffset: -5, topLeftYOffset: -5, topRightYOffset: -10, bottomRightXOffset: -5, topLeftCornerRadius: 20, bottomLeftCornerRadius: 20)
            .foregroundStyle(.white.opacity(0.2))
    )
    }
}

#Preview {
    RedTeamList()
}

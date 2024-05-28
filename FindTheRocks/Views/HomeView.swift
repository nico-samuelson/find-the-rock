//
//  HomeView.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 28/05/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack() {
            GeometryReader { gp in
//                VStack(alignment:.leading,spacing:0){
                    VStack{
                        Text("Find")
                            .font(.title)
                        Text("ThE ROCK")
                            .font(.largeTitle)
                    }
                    .frame(minWidth:gp.size.width,minHeight:gp.size.height/2)
                    .background{
                        RoundedRectangle(cornerRadius: 40)
                            .foregroundColor(.blue)
                    }
//                }
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    HomeView()
}

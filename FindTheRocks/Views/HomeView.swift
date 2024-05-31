//
//  HomeView.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 28/05/24.
//

import SwiftUI

struct HomeView: View {
    @State private var name: String = "Nico Samuel"
    @Binding var multiPeerSession: MultipeerSession
    @State private var keyboardHeight:CGFloat = 0
    @State private var isFocused:Bool = false
    @State private var avatarOffset: CGSize = .zero
    @State private var avatarOpacity: Double = 1.0
    @State private var avatarIndex: Int = 0
    @State private var isInvited:Bool = false
    @State private var time:Int  = 15
    
    let avatarImageNames = ["lancelot-avatar", "tigreal-avatar"]
    
    var body: some View {
        NavigationStack() {
            GeometryReader { gp in
                ZStack{
                    VStack(alignment:.center,spacing:0){
                        VStack{
                            Text("Find")
                                .font(.custom("Roboto", size:40))
                                .foregroundStyle(.white)
                                .padding(.top,40)
                                .rotationEffect(.degrees(-3))
                            Text("ThE ROCK")
                                .font(.custom("Roboto",size:40))
                                .foregroundStyle(.white)
                                .bold()
                                .rotationEffect(.degrees(-3))
                        }
                        .frame(minWidth:gp.size.width,minHeight:gp.size.height/30*7)
                        .background{
                            SkewedRoundedRectangle(bottomRightYOffset: 20,cornerRadius: 30)
                                .fill(Color.primaryGradient)
                                .shadow(color:.init(.black.opacity(0.25)),radius: 20,x:0,y:4)
                        }
                        Spacer()
                        Image(systemName: "magnifyingglass.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:gp.size.width/2)
                        Spacer()
                        
                        /// Bottom Action BAR
                        VStack(){
                            Image(avatarImageNames[avatarIndex])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .frame(width:75,height:75)
                                .background{
                                    Circle()
                                        .fill(.white.opacity(0.2))
                                        .frame(width:85,height:85)
                                }
                                .padding(.top,-35)
                                .offset(avatarOffset)
                                .opacity(avatarOpacity)
                            //                            .gesture(
                            //                                DragGesture()
                            //                                    .onChanged { value in
                            //                                        avatarOffset = value.translation
                            //                                        avatarOpacity = 0.5 // Change opacity when dragging
                            //                                    }
                            //                                    .onEnded { value in
                            //                                        // Reset offset and opacity when drag ends
                            //                                        withAnimation {
                            //                                            avatarOffset = .zero
                            //                                            avatarOpacity = 1.0
                            //                                            // Change the image source if dragged beyond a threshold
                            //                                            let threshold: CGFloat = 100
                            //                                            if abs(value.translation.width) > threshold {
                            //                                                let increment = value.translation.width > 0 ? 1 : -1
                            //                                                avatarIndex = (avatarIndex + increment + avatarImageNames.count) % avatarImageNames.count
                            //                                            }
                            //                                        }
                            //                                    }
                            //                            )
                                .onTapGesture(){
                                    avatarIndex = (avatarIndex + 1) % avatarImageNames.count
                                }
                            
                            Spacer()
                                .frame(height:25)
                            
                            
                            HStack(alignment:.center,spacing:0){
                                TextField("", text: $name)
                                    .font(.custom("Roboto", size: 27, relativeTo: .title))
                                    .foregroundColor(isFocused ? Color.init(red:142/255.0,green:111/255.0,blue:255/255.0) : .white)
                                    .padding(.leading,30)
                                    .frame(maxWidth:225,maxHeight:60)
                                    .background(){
                                        if isFocused {
                                            Rectangle()
                                                .fill(.white.opacity(0.8))
                                        }
                                        else{
                                            Rectangle()
                                                .fill(.white.opacity(0.2))
                                        }
                                    }
                                
                                Image(systemName: "pencil")
                                    .foregroundStyle(isFocused ? Color.init(red:142/255.0,green:111/255.0,blue:255/255.0) : .white)
                                    .font(.title)
                                    .bold()
                                    .frame(width:55,height:60)
                                    .background(){
                                        if isFocused {
                                            Rectangle()
                                                .fill(.white.opacity(1))
                                        }
                                        else{
                                            Rectangle()
                                                .fill(.white.opacity(0.5))
                                        }
                                    }
                            }
                            .clipShape(SkewedRoundedRectangle(topLeftXOffset: 2,topRightXOffset: 2,bottomRightYOffset: 4, cornerRadius: 20))
                            .keyboardHeight($keyboardHeight,hide:hideKeyboard)
                            .offset(y: -keyboardHeight * 0.6)
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.25)) {
                                    isFocused = true
                                }
                            }
                            
                            Spacer()
                                .frame(height:12)
                            NavigationLink(destination: RoomView(multiPeerSession: $multiPeerSession),label:{
                                Text("CREATE ROOM")
                                    .font(.custom("Roboto",size:28,relativeTo: .title))
                                    .foregroundStyle(.white)
                                    .bold()
                                    .padding(20)
                                    .padding(.horizontal,24)
                                    .background(){
                                        SkewedRoundedRectangle(topLeftYOffset: 5,bottomRightXOffset: 5,bottomLeftXOffset: 5,cornerRadius: 20)
                                            .fill(Color.tersierGradient)
                                    }
                            })
                            Spacer()
                        }.frame(width:gp.size.width,height:gp.size.height/30*9)
                            .background(){
                                CustomRandomShape()
                                    .fill(Color.primaryGradient)
                                    .shadow(color:.init(.black.opacity(0.33)),radius: 20,x:0,y:4)
                            }
                    }
                    .background(Color.clear)  // Add a clear background to detect taps outside
                    .contentShape(Rectangle())  // Define the tap area as the whole view
                    .onTapGesture {
                        hideKeyboard()
                    }
                }
                
//                Modal for invitation
                if isInvited {
                    VStack{
                        Spacer()
                        HStack{
                            Spacer()
                            VStack(alignment:.center){
                                Spacer()
                                    .frame(height:12)
                                Text("INVITATION")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .bold()
                                Spacer()
                                HStack(){
                                    Spacer()
                                    Image("lancelot-avatar")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(Circle())
                                        .frame(width:50,height:50)
                                        .background{
                                            Circle()
                                                .fill(.white.opacity(0.2))
                                                .frame(width:60,height:60)
                                        }
                                    Spacer()
                                        .frame(width:12)
                                    Text("Nico Samuel")
                                        .font(.custom("Roboto",size:26))
                                        .foregroundStyle(.white)
                                        .bold()
                                    Spacer()
                                }
                                Spacer()
                                HStack{
                                    Spacer()
                                    Text("Decline")
                                        .font(.custom("Roboto",size:18,relativeTo: .title))
                                        .foregroundStyle(Color.init(red: 142/255.0,green:111/255.0,blue:255/255.0))
                                        .bold()
                                        .frame(width:(gp.size.width/2) - 40,height:40)
                                        .background(){
                                            SkewedRoundedRectangle(topLeftYOffset: 2,topRightXOffset:2,cornerRadius: 10)
                                                .fill(Color.white)
                                        }
                                        .onTapGesture{
                                            withAnimation{
                                                isInvited = false
                                            }
                                        }
                                    Text("Accept (\(time))")
                                        .font(.custom("Roboto",size:18,relativeTo: .title))
                                        .foregroundStyle(.white)
                                        .bold()
                                        .frame(width:(gp.size.width/2) - 40,height:40)
                                        .background(){
                                            SkewedRoundedRectangle(topLeftYOffset: 2,bottomRightXOffset: 2,bottomLeftXOffset: 2,cornerRadius: 10)
                                                .fill(Color.tersierGradient)
                                        }
                                    Spacer()
                                }
                                Spacer()
                                    .frame(height:20)
                            }
                            .frame(width:gp.size.width - 40, height: gp.size.height*0.23)
                            .background(){
                                SkewedRoundedRectangle(topLeftXOffset: 5,topRightYOffset: 5,bottomRightYOffset: 5,cornerRadius: 20)
                                    .fill(Color.primaryGradient)
                            }
                            Spacer()
                        }
                        Spacer()
                    }.frame(width:gp.size.width,height:gp.size.height)
                        .background(){
                            Color.white.opacity(0.5)
                                .blur(radius:10)
                        }
                }
            }
            .background(Color.secondaryGradient)
            .ignoresSafeArea()
            .onAppear(){
                invited()
            }
        }
    }
    
    func invited(_ player: Player? = nil){
//        inviting player
        isInvited = true
        time = 15
        cooldown()
    }
    
    private func cooldown(){
        if time > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                time -= 1
                cooldown() // Recursive call to continue the countdown
            }
        } else {
            withAnimation {
                isInvited = false
            }
        }
    }
    
    private func hideKeyboard() {
        if keyboardHeight > 0 {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            print("Text Hide")
            isFocused = false
            print("Text")
            if name != multiPeerSession.getDisplayName() {
                let displayName = name.isEmpty ? "Default" : name
                multiPeerSession.updateDisplayName(displayName)
            }
        } else {
            isFocused = false
            print("Text 2")
        }
    }
}

struct KeyboardProvider: ViewModifier {
    
    var keyboardHeight: Binding<CGFloat>
    var hideKeyboard: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification),
                       perform: { notification in
                guard let userInfo = notification.userInfo,
                      let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                
                self.keyboardHeight.wrappedValue = keyboardRect.height
                print("Show Keyboard")
                
                
            }).onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification),
                         perform: { _ in
                self.keyboardHeight.wrappedValue = 0
                print("Hide Keyboard")
                hideKeyboard()
            })
    }
}


public extension View {
    func keyboardHeight(_ state: Binding<CGFloat>,hide: @escaping () -> Void ) -> some View {
        self.modifier(KeyboardProvider(keyboardHeight: state, hideKeyboard: hide))
    }
}

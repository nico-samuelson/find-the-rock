//
//  HomeView.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 28/05/24.
//

import SwiftUI
import SceneKit
import MultipeerConnectivity

struct HomeView: View {
    @Environment(AudioObservable.self) var audio
    @State private var name: String = ""
    @Binding var multiPeerSession: MultipeerSession
    @State private var keyboardHeight:CGFloat = 0
    @State private var isFocused:Bool = false
    @State private var avatarOffset: CGSize = .zero
    @State private var avatarOpacity: Double = 1.0
    @State private var avatarIndex: Int = UserDefaults.standard.integer(forKey: "avatar")
    @State private var isInvited:Bool = false
    @State private var time:Int  = 15
    @State private var inviterName:String?
    @State private var inviterProfile:String = "lancelot-avatar"
    @State private var invitationHandler: ((Bool) -> Void)?
    @State private var topOffset:CGFloat = -100
    @State private var botOffset:CGFloat = -100
    @State private var navigateRoom = false
    @State private var navigateWait = false
    @State private var isShowRock = false
    
    var rockScene: SCNScene = Self.loadScene(named: "art.scnassets/models/rock-home.scn")
    
    let avatarImageNames = ["male-avatar", "female-avatar"]
    
    var body: some View {
        NavigationStack() {
            GeometryReader { gp in
                ZStack{
                    VStack(alignment:.center,spacing:0){
                        VStack{
                            Text("Find")
                                .font(.custom("TitanOne", size:40))
                                .foregroundStyle(.white)
                                .padding(.top,40)
                                .rotationEffect(.degrees(-3))
                            Text("ThE ROCK")
                                .font(.custom("TitanOne",size:40))
                                .foregroundStyle(.white)
                                .bold()
                                .rotationEffect(.degrees(-3))
                        }
                        .frame(minWidth:gp.size.width,minHeight:gp.size.height/30*7)
                        .background{
                            SkewedRoundedRectangle(bottomRightYOffset: 20, bottomLeftCornerRadius: 30, bottomRightCornerRadius: 30)
                                .fill(Color.primaryGradient)
                                .shadow(color:.init(.black.opacity(0.25)),radius: 20,x:0,y:4)
                        }
                        .offset(x:0,y: topOffset - (gp.size.height/30*5))
                        Spacer()
                        
                        if isShowRock {
                            LegacySceneView(scene: rockScene)
                                .frame(width: gp.size.width)
                        }
                        // 3d Asset
                        Spacer()
                        
                        /// Bottom Action BAR
                        VStack(spacing: 0){
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
                                .onTapGesture(){
                                    audio.playClick()
                                    avatarIndex = (avatarIndex + 1) % avatarImageNames.count
                                    UserDefaults.standard.setValue(avatarIndex,forKey:"avatar")
                                    multiPeerSession.changeAvatar(avatarIndex)
                                }
                            
                            Spacer()
                                .frame(height:25)
                            
                            
                            HStack(alignment:.center,spacing:0){
                                TextField("", text: $name)
                                    .font(.custom("Staatliches-Regular", size: 36, relativeTo: .title))
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
                                audio.playClick()
                                withAnimation(.easeOut(duration: 0.25)) {
                                    isFocused = true
                                }
                            }
                            
                            Button(action: {
                                audio.playClick()
                                // Your custom logic here
                                // e.g., update some state, print a message, etc.
                                audio.playClick()
                                multiPeerSession.createRoom()
                                multiPeerSession.room.teams[0].players.append(Player(peerID: multiPeerSession.getPeerId(), profile:avatarImageNames[avatarIndex], status: .connected, point: 0, isPlanter: true))
                                
                                // After your logic, set navigateToHome to true to trigger navigation
                                navigateRoom = true
                            }) {
                                SkewedRoundedRectangle(topLeftYOffset: 5,bottomRightXOffset: 5,bottomLeftXOffset: 5,cornerRadius: 20)
                                    .padding(20)
                                    .padding(.horizontal, 24)
                                    .foregroundStyle(Color.tersierGradient)
                                    .overlay(
                                        Text("CREATE ROOM")
                                            .foregroundStyle(.white)
                                            .fontWeight(.bold)
                                            .font(.custom("Staatliches-Regular",size: 36))
                                    )
                            }
                            .navigationDestination(isPresented: $navigateRoom){
                                RoomView(multiPeerSession: $multiPeerSession, myself: Player(peerID: multiPeerSession.getPeerId(), profile: avatarImageNames[avatarIndex], status: .connected, point: 0, isPlanter: true))
                            }
                            .offset(y: -10)
                            //                            .padding(.bottom, 10)
                            Spacer()
                                .frame(height: 20)
                        }
                        .frame(width:gp.size.width,height:gp.size.height/30*9)
                        .background{
                            CustomRandomShape()
                                .fill(Color.primaryGradient)
                                .shadow(color:.init(.black.opacity(0.33)),radius: 20,x:0,y:4)
                        }
                        .offset(x:0,y:(gp.size.height/30*7) - botOffset)
                    }
                    .background(Color.clear)  // Add a clear background to detect taps outside
                    .contentShape(Rectangle())  // Define the tap area as the whole view
                    .onTapGesture {
                        hideKeyboard()
                    }
                    .onAppear(){
                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.05){
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.4)){
                                topOffset = gp.size.height/30*5
                                botOffset = gp.size.height/30*7
                            }
                        }
                    }
                }
                
                //  Modal for invitation
                if isInvited {
                    VStack{
                        Spacer()
                        HStack{
                            Spacer()
                            VStack(alignment:.center){
                                Spacer()
                                    .frame(height:12)
                                Text("INVITATION")
                                    .font(.custom("TitanOne",size:30))
                                    .foregroundStyle(.white)
                                    .bold()
                                Spacer()
                                HStack(){
                                    Spacer()
                                    Image(inviterProfile)
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
                                    Text(inviterName!)
                                        .font(.custom("TitanOne",size:26))
                                        .foregroundStyle(.white)
                                        .bold()
                                    Spacer()
                                }
                                Spacer()
                                HStack{
                                    Spacer()
                                    Text("Decline")
                                        .font(.custom("Staatliches-Regular",size:18,relativeTo: .title))
                                        .foregroundStyle(Color.init(red: 142/255.0,green:111/255.0,blue:255/255.0))
                                        .bold()
                                        .frame(width:(gp.size.width/2) - 40,height:40)
                                        .background(){
                                            SkewedRoundedRectangle(topLeftYOffset: 2,topRightXOffset:2,cornerRadius: 10)
                                                .fill(Color.white)
                                        }
                                        .onTapGesture{
                                            audio.playClick()
                                            withAnimation{
                                                isInvited = false
                                                invitationHandler?(false)
                                                self.invitationHandler = nil
                                            }
                                        }
                                    
                                    
                                    Button(action: {
                                        audio.playClick()
                                        invitationHandler?(true)
                                        invitationHandler = nil
                                        // Adding a slight delay before navigating
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            navigateWait = true
                                            print("harusnya pindah")
                                        }
                                        isInvited = false
                                    }) {
                                        SkewedRoundedRectangle(topLeftYOffset: 2,bottomRightXOffset: 2,bottomLeftXOffset: 2,cornerRadius: 10)
                                            .fill(Color.tersierGradient)
                                            .frame(width:(gp.size.width/2) - 40,height:40)
                                            .overlay(
                                                Text("Accept \(time)")
                                                    .foregroundStyle(.white)
                                                    .fontWeight(.bold)
                                                    .font(.custom("Staatliches-Regular",size: 18))
                                            )
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
            .navigationDestination(isPresented: $navigateWait){
                WaitingView(multiPeerSession: $multiPeerSession)
            }
            .background(Color.secondaryGradient)
            .ignoresSafeArea()
            .onAppear(){
                multiPeerSession.showInviteModal = { profile, peerId, invitationHandler in
                    inviterName = peerId.displayName
                    inviterProfile = profile
                    self.invitationHandler = invitationHandler
                    isInvited = true
                    time = 15
                    cooldown()
                }
                name = multiPeerSession.getDisplayName()
                print(multiPeerSession.connectedPeers.map({$0.displayName}))
                DispatchQueue.main.asyncAfter(deadline:.now() + 0.2){
                    withAnimation(.easeOut(duration:0.2)){
                        isShowRock = true
                    }
                }
            }
            .navigationBarBackButtonHidden()
        }
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
                invitationHandler?(false)
                self.invitationHandler = nil
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
                UserDefaults.standard.setValue(displayName,forKey: "display_name")
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
    
    static func loadScene(named modelName: String) -> SCNScene {
        guard let scene = SCNScene(named: modelName) else {
            print("cannot find \(modelName)")
            abort()
        }
        scene.background.contents = UIColor.clear
        return scene
    }
    
    static func loadScene(named modelName: String, scale: CGFloat) -> SCNScene {
        guard let scene = SCNScene(named: modelName) else {
            print("cannot find \(modelName)")
            abort()
        }
        scene.background.contents = UIColor.clear
        
        // Apply scale to all root node's childNodes
        for childNode in scene.rootNode.childNodes {
            childNode.scale = SCNVector3(scale, scale, scale)
        }
        
        return scene
    }
}

struct LegacySceneView: UIViewRepresentable {
    var scene: SCNScene
    let view = SCNView()
    var lastPanLocation: CGPoint? // Keep track of the last pan location
    var currentAngleY: Float = 0.0
    
    init(scene: SCNScene) {
        self.scene = scene
    }
    
    func makeUIView(context: Context) -> SCNView {
        // get camera from scene
        let cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)?.camera
        scene.rootNode.camera = cameraNode
        
        view.scene = scene
        view.backgroundColor = UIColor.clear
        view.isUserInteractionEnabled = false
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // ... existing code ...
    }
    
}

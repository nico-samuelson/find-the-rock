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
    @State private var name: String = ""
    @Binding var multiPeerSession: MultipeerSession
    @State private var keyboardHeight:CGFloat = 0
    @State private var isFocused:Bool = false
    @State private var avatarOffset: CGSize = .zero
    @State private var avatarOpacity: Double = 1.0
    @State private var avatarIndex: Int = 0
    @State private var isInvited:Bool = false
    @State private var time:Int  = 15
    @State private var inviterName:String?
    @State private var inviterProfile:String = "lancelot-avatar"
    @State private var invitationHandler: ((Bool) -> Void)?
    @State private var topOffset:CGFloat = 0
    @State private var botOffset:CGFloat = 0
    
    let avatarImageNames = ["lancelot-avatar", "tigreal-avatar"]
    
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
                            SkewedRoundedRectangle(bottomRightYOffset: 20,cornerRadius: 30)
                                .fill(Color.primaryGradient)
                                .shadow(color:.init(.black.opacity(0.25)),radius: 20,x:0,y:4)
                        }
                        .offset(x:0,y: topOffset - (gp.size.height/30*5))
                        Spacer()
                        // 3d Asset
                        LegacySceneView(scene: Self.loadScene(named: "art.scnassets/models/rock-home.scn"))
                            .frame(width: gp.size.width)
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
                                .onTapGesture(){
                                    avatarIndex = (avatarIndex + 1) % avatarImageNames.count
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
                                withAnimation(.easeOut(duration: 0.25)) {
                                    isFocused = true
                                }
                            }
                            
                            Spacer()
                                .frame(height:12)
                            NavigationLink(destination: RoomView(multiPeerSession: $multiPeerSession, myself: Player(peerID: multiPeerSession.getPeerId(), profile:"lancelot-avatar", status: .connected, point: 0)),label:{
                                Text("CREATE ROOM")
                                    .font(.custom("Staatliches-Regular",size:36,relativeTo: .title))
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
                        }
                        .frame(width:gp.size.width,height:gp.size.height/30*9)
                            .background(){
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
                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.1){
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
                                            withAnimation{
                                                isInvited = false
                                                invitationHandler?(false)
                                                self.invitationHandler = nil
                                            }
                                        }
                                    NavigationLink(destination: WaitingView(multiPeerSession: $multiPeerSession,isInvited: $isInvited, invitationHandler: $invitationHandler),label:{
                                        Text("Accept \(time)")
                                            .font(.custom("Staatliches-Regular",size:18,relativeTo: .title))
                                            .foregroundStyle(.white)
                                            .bold()
                                            .frame(width:(gp.size.width/2) - 40,height:40)
                                            .background(){
                                                SkewedRoundedRectangle(topLeftYOffset: 2,bottomRightXOffset: 2,bottomLeftXOffset: 2,cornerRadius: 10)
                                                    .fill(Color.tersierGradient)
                                            }
                                    })
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
        //        view.pointOfView = cameraNode
        //        view.allowsCameraControl = true
        //        view.autoenablesDefaultLighting = true
        view.isUserInteractionEnabled = false
        //        view.isMultipleTouchEnabled = false
        
        //        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        //        view.addGestureRecognizer(panGesture)
        //
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // ... existing code ...
    }
    
    //
    //
    //    class Coordinator: NSObject {
    //            var parent: LegacySceneView
    //
    //            init(_ parent: LegacySceneView) {
    //                self.parent = parent
    //            }
    //
    //            @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
    //                let translation = gesture.translation(in: gesture.view!)
    //                let x = Float(translation.x)
    //
    //                if let modelNode = parent.scene.rootNode.childNode(withName: "rock", recursively: true) {
    //                    var newAngleY = (x * Float(Double.pi)) / 180.0
    //                    newAngleY += parent.currentAngleY
    //                    modelNode.eulerAngles.y = newAngleY
    //
    //                    if gesture.state == .ended {
    //                        parent.currentAngleY = newAngleY
    //                    }
    //                }
    //            }
    //        }
}

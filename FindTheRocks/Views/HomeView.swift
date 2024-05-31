//
//  HomeView.swift
//  FindTheRocks
//
//  Created by Christopher Julius on 28/05/24.
//

import SwiftUI
import SceneKit

struct HomeView: View {
    var body: some View {
        NavigationStack() {
            GeometryReader { gp in
                VStack(alignment:.center,spacing:0){
                    VStack{
                        Text("Find")
                            .font(.title)
                            .foregroundStyle(.white)
                            .bold()
                            .padding(.top,40)
                        Text("ThE ROCK")
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                            .bold()
                    }
                    .frame(minWidth:gp.size.width,minHeight:gp.size.height/30*7)
                    .background{
                        SkewedRoundedRectangle(bottomRightYOffset: 20,cornerRadius: 30)
                            .fill(Color.primaryGradient)
                            .shadow(color:.init(.black.opacity(0.25)),radius: 20,x:0,y:4)
                    }
                    Spacer()
//                    Image(systemName: "magnifyingglass.circle.fill")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width:gp.size.width/2)
                    // 3d Asset
                    LegacySceneView(scene: Self.loadScene(named: "art.scnassets/models/rock.scn"))
                        .frame(width: gp.size.width)
                    Spacer()
                    
                    VStack(){
                        Image("lancelot-avatar")
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
                            
                        Spacer()
                            .frame(height:25)
                        
                        
                        HStack(alignment:.center,spacing:0){
                            VStack{
                                Spacer()
                                    .frame(height:10)
                                Text("Nico Samuel")
                                    .font(.title)
                                    .foregroundStyle(.white)
                                    .bold()
                                    .padding(.horizontal,28)
                                Spacer()
                                    .frame(height:10)
                            }
                            .background(){
                                Rectangle()
                                    .fill(.white.opacity(0.2))
                            }
                            VStack{
                                Spacer()
                                    .frame(height:12)
                                Image(systemName: "pencil")
                                    .foregroundStyle(.white)
                                    .font(.title)
                                    .bold()
                                    .padding(.horizontal,16)
                                Spacer()
                                    .frame(height:12)
                            }
                            .background(){
                                Rectangle()
                                    .fill(Color.white.opacity(0.5))
                            }
                        }
                        .clipShape(SkewedRoundedRectangle(topLeftXOffset: 2,topRightXOffset: 2,bottomRightYOffset: 0.56, cornerRadius: 20))
                        Spacer()
                            .frame(height:12)
                        Text("CREATE ROOM")
                            .font(.title)
                            .foregroundStyle(.white)
                            .bold()
                            .padding(20)
                            .padding(.horizontal,24)
                            .background(){
                                SkewedRoundedRectangle(topLeftYOffset: 5,bottomRightXOffset: 5,bottomLeftXOffset: 5,cornerRadius: 20)
                                    .fill(Color.tersierGradient)
                            }
                        Spacer()
                    }.frame(width:gp.size.width,height:gp.size.height/30*9)
                    .background(){
                        CustomRandomShape()
                            .fill(Color.primaryGradient)
                            .shadow(color:.init(.black.opacity(0.33)),radius: 20,x:0,y:4)
                    }
                }
            }
            .background(Color.secondaryGradient)
            .ignoresSafeArea()
        }
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
        view.allowsCameraControl = true
//        view.autoenablesDefaultLighting = true
        view.isUserInteractionEnabled = true
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

#Preview {
    HomeView()
}

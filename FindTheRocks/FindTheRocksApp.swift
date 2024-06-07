//
//  FindTheRocksApp.swift
//  FindTheRocks
//
//  Created by Nico Samuelson on 28/05/24.
//

import SwiftUI
import SwiftData

@main
struct FindTheRocksApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var multipeerSession: MultipeerSession = MultipeerSession(displayName: UserDefaults.standard.string(forKey:"display_name") ?? UIDevice.current.systemName)
    @State var audio = AudioObservable()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(multipeerSession: $multipeerSession)
                .environment(audio)
        }
        .modelContainer(sharedModelContainer)
    }
}

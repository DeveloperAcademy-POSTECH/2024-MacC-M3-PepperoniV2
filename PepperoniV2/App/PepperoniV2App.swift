//
//  PepperoniV2App.swift
//  PepperoniV2
//
//  Created by 변준섭 on 11/14/24.
//

import SwiftUI
import SwiftData

@main
struct PepperoniV2App: App {
    var modelContainer: ModelContainer = {
        let schema = Schema([Anime.self, AnimeQuote.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(modelContainer)
    }
}

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
    @State private var fetchDataState = FetchDataState()
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
                .environment(fetchDataState)
                .onAppear {
                    NotificationCenter.default.addObserver(
                        forName: AppDelegate.anonymousSignInCompleted,
                        object: nil,
                        queue: .main
                    ) { _ in
                        Task {
                            await MainActor.run {
                                let context = modelContainer.mainContext
                                Task {
                                    do {
                                        try await FirestoreService().fetchAnimeTitles(context: context)
                                        fetchDataState.isFetchingData = false
                                    } catch {
                                        fetchDataState.errorMessage = error.localizedDescription
                                        fetchDataState.isFetchingData = false
                                    }
                                }
                            }
                        }
                    }
                }
                .onDisappear {
                    NotificationCenter.default.removeObserver(self, name: AppDelegate.anonymousSignInCompleted, object: nil)
                }
        }
        .modelContainer(modelContainer)
    }
}

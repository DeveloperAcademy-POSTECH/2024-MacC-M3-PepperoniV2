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
                    Task {
                        do {
                            let context = modelContainer.mainContext
                            try await FirestoreService().fetchAndStoreData(context: context)
                            fetchDataState.isFetchingData = false // 데이터 로드 완료
                        } catch {
                            print("Failed to fetch and store data: \(error.localizedDescription)")
                            fetchDataState.isFetchingData = false // 데이터 로드 실패
                        }
                    }
                }
        }
        .modelContainer(modelContainer)
    }
}

//
//  ContentView.swift
//  PepperoniV2
//
//  Created by 변준섭 on 11/14/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var router = Router()
    @State var gameData = GameData()
    
    @State var gameViewModel = GameViewModel()
    @EnvironmentObject var fetchDataState: FetchDataState
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack(path: $router.route) {
            HomeView()
                .environmentObject(router)
                .environment(gameData)
                .environment(gameViewModel)
                .navigationDestination(for: Game.self) { type in
                    GameView(type: type)
                        .environmentObject(router)
                        .environment(gameViewModel)
                }
                .onAppear {
                    Task {
                        do {
                            try await FirestoreService().fetchAndStoreData(context: modelContext)
                            DispatchQueue.main.async {
                                fetchDataState.isFetchingData = false
                            }
                        } catch {
                            DispatchQueue.main.async {
                                fetchDataState.errorMessage = error.localizedDescription
                                fetchDataState.isFetchingData = false
                            }
                        }
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}

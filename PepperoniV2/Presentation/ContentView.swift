//
//  ContentView.swift
//  PepperoniV2
//
//  Created by 변준섭 on 11/14/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.route) {
            HomeView()
                .environmentObject(router)
                .navigationDestination(for: Game.self) { type in
                    GameView(type: type)
                        .environmentObject(router)
                }
        }
    }
}

#Preview {
    ContentView()
}

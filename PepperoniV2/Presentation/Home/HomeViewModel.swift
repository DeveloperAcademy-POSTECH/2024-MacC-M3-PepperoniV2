//
//  HomeViewMode.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/16/24.
//

import SwiftUI

@Observable class HomeViewModel {
    private(set) var gameData: GameData

    init(gameData: GameData) {
        self.gameData = gameData
    }

    func setRandomQuote() {
        guard let quotes = gameData.selectedAnime?.quotes, !quotes.isEmpty else {
            gameData.selectedQuote = nil
            return
        }
        gameData.selectedQuote = quotes.randomElement()
    }
}

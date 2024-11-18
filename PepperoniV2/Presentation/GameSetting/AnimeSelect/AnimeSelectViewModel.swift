//
//  AnimeSelectViewModel.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/19/24.
//

import SwiftUI

@Observable class AnimeSelectViewModel {
    private(set) var gameData: GameData
    private(set) var tempSelectedAnime: Anime?

    init(gameData: GameData) {
        self.gameData = gameData
        self.tempSelectedAnime = gameData.selectedAnime
    }

    /// anime 선택
    func selectAnime(_ anime: Anime) {
        tempSelectedAnime = anime
    }
    
    /// 변경사항 저장
    func saveChanges() {
        gameData.selectedAnime = tempSelectedAnime
    }
}

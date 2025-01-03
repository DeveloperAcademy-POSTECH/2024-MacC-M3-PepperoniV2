//
//  GameViewModel.swift
//  PepperoniV2
//
//  Created by 변준섭 on 11/19/24.
//

import SwiftUI

@Observable class GameViewModel {

    var selectedAnime: Anime?
    var selectedQuote: AnimeQuote?
    var players: [Player]
    var turnComplete: Int = 0
    
    var temporaryPronunciationScore: Double = 0.0
    var temporarySpeedScore: Double = 0.0
    var temporaryIntonationScore: Double = 0.0

    init(selectedAnime: Anime? = nil, selectedQuote: AnimeQuote? = nil, players: [Player] = []) {
        self.selectedAnime = selectedAnime
        self.selectedQuote = selectedQuote
        self.players = players
    }
    
    func retryThisQuote() {
        for index in players.indices {
            players[index].score = 0
        }
    }
    
    func changeTurn(first: Player) {
        print("changeTurn")
        print("Before:", players)
        
        // 첫 번째 플레이어의 인덱스를 찾는다.
        guard let firstIndex = players.firstIndex(where: { $0.nickname == first.nickname }) else {
            print("First player not found")
            return
        }
        
        // 배열을 재정렬하여 첫 번째 플레이어를 기준으로 순서를 바꾼다.
        players = Array(players[firstIndex...] + players[..<firstIndex])
        
        // 순서를 기반으로 turn 값을 재설정한다.
        for (index, _) in players.enumerated() {
            players[index].turn = index + 1 // turn 값을 1부터 시작
        }
        
        print("After:", players)
    }
}

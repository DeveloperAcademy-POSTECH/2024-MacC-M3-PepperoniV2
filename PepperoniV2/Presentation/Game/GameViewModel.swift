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

    init(selectedAnime: Anime? = nil, selectedQuote: AnimeQuote? = nil, players: [Player] = []) {
        self.selectedAnime = selectedAnime
        self.selectedQuote = selectedQuote
        self.players = players
    }
    
    func changeTurn(first: Player) {
        print("changeTurn")
        // 첫 번째 플레이어의 turn을 1로 설정
        guard let firstIndex = players.firstIndex(where: { $0.nickname == first.nickname }) else { return }
        self.players[firstIndex].turn = 1
        
        print(firstIndex)

        // 나머지 플레이어들의 turn을 업데이트
        var turn = 2
        for (index, player) in players.enumerated() {
            if index != firstIndex {
                var updatedPlayer = player // 복사본 생성
                updatedPlayer.turn = turn
                players[index] = updatedPlayer // 복사본을 배열에 다시 할당
                turn += 1
            }
        }
    }
}

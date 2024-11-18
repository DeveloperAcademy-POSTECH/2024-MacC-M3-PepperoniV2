//
//  PlayerSettingViewModel.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/18/24.
//

import SwiftUI

@Observable class PlayerSettingViewModel {
    private(set) var gameData: GameData

    init(gameData: GameData) {
        self.gameData = gameData
    }

    /// 플레이어 추가
    func addPlayer() {
        let newPlayer = Player(nickname: "\(gameData.players.count + 1)번", turn: gameData.players.count + 1)
        gameData.players.append(newPlayer)
    }

    /// 플레이어 제거
    func removePlayer() {
        if !gameData.players.isEmpty {
            gameData.players.removeLast()
        }
    }

    /// 닉네임 업데이트
    func updateNickname(for index: Int, nickname: String) {
        guard index < gameData.players.count else { return }
        gameData.players[index].nickname = nickname
    }
    
    /// 플레이어 초기화
    func resetPlayer() {
        gameData.players = [Player(nickname: "1번", turn: 1)] // 초기 상태
    }
}

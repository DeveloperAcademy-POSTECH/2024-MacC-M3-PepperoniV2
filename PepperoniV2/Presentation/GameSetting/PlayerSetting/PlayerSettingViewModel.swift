//
//  PlayerSettingViewModel.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/18/24.
//

import SwiftUI

@Observable class PlayerSettingViewModel {
    private(set) var gameData: GameData
    private(set) var tempPlayers: [Player]

    init(gameData: GameData) {
        self.gameData = gameData
        self.tempPlayers = gameData.players
    }

    /// 플레이어 추가
    func addPlayer() {
        let newPlayer = Player(nickname: "", turn: tempPlayers.count + 1)
        tempPlayers.append(newPlayer)
    }

    /// 플레이어 제거
    func removePlayer() {
        if !tempPlayers.isEmpty {
            tempPlayers.removeLast()
        }
    }

    /// 닉네임 업데이트
    func updateNickname(for index: Int, nickname: String) {
        guard index < tempPlayers.count else { return }
        tempPlayers[index].nickname = nickname
    }
    
    /// 플레이어 초기화
    func resetPlayer() {
        tempPlayers = [Player(turn: 1), Player(turn: 2)]
    }
    
    /// 변경사항 저장
    func saveChanges() {
        for (index, player) in tempPlayers.enumerated() {
            if player.nickname.isEmpty {
                tempPlayers[index].nickname = "\(index + 1)번"
            }
        }
        gameData.players = tempPlayers
    }
}

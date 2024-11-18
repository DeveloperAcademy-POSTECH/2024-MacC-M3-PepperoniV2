//
//  PlayerSettingViewModel.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/18/24.
//

import SwiftUI

@Observable class PlayerSettingViewModel {
    private(set) var gameData: GameData
    private(set) var tempGameData: GameData

    init(gameData: GameData) {
        self.gameData = gameData
        
        // 저장 전 임시 GameData
        self.tempGameData = GameData()
        self.tempGameData.players = gameData.players
    }

    /// 플레이어 추가
    func addPlayer() {
        let newPlayer = Player(nickname: "\(tempGameData.players.count + 1)번", turn: tempGameData.players.count + 1)
        tempGameData.players.append(newPlayer)
    }

    /// 플레이어 제거
    func removePlayer() {
        if !tempGameData.players.isEmpty {
            tempGameData.players.removeLast()
        }
    }

    /// 닉네임 업데이트
    func updateNickname(for index: Int, nickname: String) {
        guard index < tempGameData.players.count else { return }
        tempGameData.players[index].nickname = nickname
    }
    
    /// 플레이어 초기화
    func resetPlayer() {
        tempGameData.players = [Player(nickname: "1번", turn: 1)]
    }
    
    /// 변경사항 저장
    func saveChanges() {
        gameData.players = tempGameData.players
        gameData.selectedAnime = tempGameData.selectedAnime
    }
}

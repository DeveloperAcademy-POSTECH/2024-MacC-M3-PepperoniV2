//
//  HomeView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/16/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: Router
    @Environment(GameData.self) var gameData
    @Environment(GameViewModel.self) var gameViewModel
    
    @State private var isAnimeSelectPresented = false
    @State private var isPlayerSettingPresented = false

    var body: some View {
        VStack {
            Text("Home")
            
            Button {
                isAnimeSelectPresented = true
            } label: {
                Text("애니 선택")
            }
            .fullScreenCover(isPresented: $isAnimeSelectPresented) {
                AnimeSelectView(isPresented: $isAnimeSelectPresented, viewModel: AnimeSelectViewModel(gameData: gameData))
            }
            
            Button {
                isPlayerSettingPresented = true
            } label: {
                Text("인원 설정")
            }
            .fullScreenCover(isPresented: $isPlayerSettingPresented) {
                PlayerSettingView(isPresented: $isPlayerSettingPresented, viewModel: PlayerSettingViewModel(gameData: gameData))
            }
            
            Button {
                setRandomQuote()
                gameViewModel.players = gameData.players
                gameViewModel.selectedAnime = gameData.selectedAnime
                gameViewModel.selectedQuote = gameData.selectedQuote
                router.push(screen: Game.turnSetting)
            } label: {
                Text("게임 시작")
            }
            
            // TODO: 확인용 임시 코드 - 추후 삭제
            VStack {
                Text("선택한 애니: \(gameData.selectedAnime?.title ?? "없음")")
                
                List(gameData.players, id: \.turn) { player in
                    Text(player.nickname ?? "")
                }
            }
        }
    }
    
    // 랜덤으로 quote를 선택
    private func setRandomQuote() {
        guard let quotes = gameData.selectedAnime?.quotes, !quotes.isEmpty else {
            gameData.selectedQuote = nil
            return
        }
        gameData.selectedQuote = quotes.randomElement()
    }
}

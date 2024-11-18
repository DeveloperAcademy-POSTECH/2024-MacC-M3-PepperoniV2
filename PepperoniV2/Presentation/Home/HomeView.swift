//
//  HomeView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/16/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: Router
    @State var gameData = GameData()
    
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
                AnimeSelectView(isPresented: $isAnimeSelectPresented, gameData: gameData)
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
}

#Preview {
    HomeView()
}

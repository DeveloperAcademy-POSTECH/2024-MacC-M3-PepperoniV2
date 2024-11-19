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
    @State var viewModel: HomeViewModel
    
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
                viewModel.setRandomQuote()
                print("\(viewModel.gameData.selectedQuote?.korean[0] ?? "nono")")
                router.push(screen: Game.turnSetting)
            } label: {
                Text("게임 시작")
            }
            
            // TODO: 확인용 임시 코드 - 추후 삭제
            VStack {
                Text("선택한 애니: \(viewModel.gameData.selectedAnime?.title ?? "없음")")
                
                List(viewModel.gameData.players, id: \.turn) { player in
                    Text(player.nickname ?? "")
                }
            }
        }
    }
}
//
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        let gameData = GameData()
//        let viewModel = HomeViewModel(gameData: gameData)
//        
//        return HomeView(gameData: gameData, viewModel: viewModel)
//    }
//}

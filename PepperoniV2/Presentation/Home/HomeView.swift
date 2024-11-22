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
    
    var isGameStartEnabled: Bool {
        guard let selectedAnime = gameData.selectedAnime else { return false }
        return !selectedAnime.title.isEmpty && gameData.players.count >= 2
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("DUKBAM")
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(Color(red: 0.19, green: 0.19, blue: 0.22))
                .padding(.bottom, 45)
            
            // MARK: -애니 선택
            VStack {
                if let selectedAnime = gameData.selectedAnime {
                    SelectedAnimeView(title: selectedAnime.title)
                } else {
                    SelectButtonView(
                        title: "애니를 선택해 주세요",
                        height: 128
                    )
                }
            }
            .padding(.bottom, 16)
            .onTapGesture {
                isAnimeSelectPresented = true
            }
            .fullScreenCover(isPresented: $isAnimeSelectPresented) {
                AnimeSelectView(isPresented: $isAnimeSelectPresented, viewModel: AnimeSelectViewModel(gameData: gameData))
            }
            
            // MARK: -인원 선택
            VStack {
                if gameData.players.count < 2 {
                    SelectButtonView(
                        title: "인원을 넣어주세요",
                        height: 293
                    )
                } else {
                    SelectedPlayerView(playerCount: gameData.players.count)
                }
            }
            .padding(.bottom, 36)
            .onTapGesture {
                isPlayerSettingPresented = true
            }
            .fullScreenCover(isPresented: $isPlayerSettingPresented) {
                PlayerSettingView(isPresented: $isPlayerSettingPresented, viewModel: PlayerSettingViewModel(gameData: gameData))
            }
            
            // MARK: -시작 버튼
            Button {
                startGame()
            } label: {
                Image(isGameStartEnabled ? "StartButton" : "StartButton_disabled")
            }
            .disabled(!isGameStartEnabled)
        }
        .padding(.horizontal)
        .background(.black)
    }
    
    private func startGame() {
        // 랜덤 Quote 설정
        setRandomQuote()
        
        // GameViewModel에 데이터 설정
        gameViewModel.players = gameData.players
        gameViewModel.selectedAnime = gameData.selectedAnime
        gameViewModel.selectedQuote = gameData.selectedQuote
        
        // 다음 화면으로 이동
        router.push(screen: Game.turnSetting)
    }
    
    /// 랜덤으로 quote를 선택
    private func setRandomQuote() {
        guard let quotes = gameData.selectedAnime?.quotes, !quotes.isEmpty else {
            gameData.selectedQuote = nil
            return
        }
        gameData.selectedQuote = quotes.randomElement()
    }
}

// MARK: -Components
// MARK: -선택 전 버튼
struct SelectButtonView: View {
    let title: String
    let height: CGFloat
    
    var body: some View {
        VStack(spacing: 16) {
            Image("PlusButton")
                .resizable()
                .scaledToFit()
                .frame(width: 41)
            
            Text(title)
                .font(.system(size: 16, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(Color.ppDarkGray_04)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.ppDarkGray_02, style: StrokeStyle(lineWidth: 2, dash: [4]))
        )
    }
}

// MARK: - 애니 선택 후 버튼
struct SelectedAnimeView: View {
    let title: String
    
    var body: some View {
        VStack {
            Text("애니 선택")
                .font(.system(size: 14, weight: .medium))
            
            VStack {
                Text(title) // selectedAnime의 제목 표시
                    .font(.system(size: 20, weight: .black))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(Color.ppPurple_01)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.ppPurple_02, lineWidth: 2)
            )
        }
        .frame(maxWidth: .infinity)
        .frame(height: 128, alignment: .bottom)
        .background(Color.ppDarkGray_02)
        .cornerRadius(10)
    }
}

// MARK: -인원 선택 후 버튼
struct SelectedPlayerView: View {
    let playerCount: Int

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Text("인원 선택")
                    .font(.system(size: 14, weight: .medium))

                VStack {
                    HStack {
                        Text(Image(systemName: "person.2.fill"))
                        Text("\(playerCount)명")
                    }
                    .font(.system(size: 20, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(Color.ppPurple_01)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.ppPurple_02, lineWidth: 2)
                )
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110, alignment: .bottom)
            .background(Color.ppDarkGray_02)
            .cornerRadius(10)

            VStack {
                PlayerGridView()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 16)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 190, alignment: .top)
            .background(Color.ppDarkGray_02)
        }
        .background(Color.ppDarkGray_02)
        .cornerRadius(20)
    }
}

struct PlayerGridView: View {
    @Environment(GameData.self) var gameData

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 8) {
            ForEach(gameData.players) { player in
                PlayerCellView(nickname: player.nickname ?? "")
                    .frame(width: 106, height: 32)
            }
        }
    }
}

struct PlayerCellView: View {
    let nickname: String
    
    var body: some View {
        VStack {
            Text(nickname)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.ppDarkGray_01)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.ppDarkGray_04)
        .cornerRadius(10)
    }
}

#Preview {
    let gameData = GameData()
    gameData.selectedAnime = Anime(id: "1", title: "주술 회전", quotes: [])
//    gameData.selectedAnime = nil
    gameData.players = [
        Player(nickname: "안녕하세요를레히", turn: 1),
        Player(nickname: "플레이어 2", turn: 2),
        Player(nickname: "플레이어 3", turn: 3),
        Player(nickname: "플레이어 3", turn: 4),
        Player(nickname: "안녕하세요를레히", turn: 1),
//        Player(nickname: "플레이어 2", turn: 2),
//        Player(nickname: "플레이어 3", turn: 3),
//        Player(nickname: "플레이어 3", turn: 4),
//        Player(nickname: "안녕하세요를레히", turn: 1),
//        Player(nickname: "안녕하세요를레히", turn: 1)
    ]
    
    let gameViewModel = GameViewModel()
    
    return HomeView()
        .environmentObject(Router())
        .environment(gameData)
        .environment(gameViewModel)
        .preferredColorScheme(.dark)
}

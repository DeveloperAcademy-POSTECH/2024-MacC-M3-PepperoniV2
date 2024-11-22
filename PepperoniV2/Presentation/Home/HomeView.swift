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
            GeometryReader { geometry in
                ZStack(alignment: .center) {
                    // 타이틀
                    Text("DUKBAM")
                        .hakgyoansim(size: 28)
                        .foregroundStyle(Color.ppWhiteGray)
                    
                    // 버튼
                    HStack {
                        Spacer()
                        
                        Button {
                            // TODO: -개발자에게 요청 구글폼!
                        } label: {
                            Image("RequestButton")
                        }
                        .foregroundStyle(.white)
                        .padding(.trailing, 16)
                        .frame(width: geometry.size.width, alignment: .trailing)
                    }
                }
            }
            .frame(height: 70, alignment: .top)
            
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
//            .disabled(!isGameStartEnabled)
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
                .hakgyoansim(size: 16)
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
        VStack(spacing: 0) {
            Text("애니 선택")
                .suit(.medium, size: 14)
                .padding(.vertical, 8)
    
            Image("AniSelectBox")
                .resizable()
                .scaledToFit()
                .frame(height: 92)
                .overlay(
                    Text(title)
                        .hakgyoansim(size: 20)
                )
        }
        .frame(maxWidth: .infinity)
        .background(Color.ppDarkGray_02)
        .cornerRadius(10)
    }
}

// MARK: -인원 선택 후 버튼
struct SelectedPlayerView: View {
    let playerCount: Int

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Rectangle()
                    .frame(height: 68)
                    .foregroundStyle(.clear)
                
                VStack{
                    VStack {
                        PlayerGridView()
                            .padding(.init(top: 57, leading: 12, bottom: 16, trailing: 12))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 225, alignment: .top)
                    .background( LinearGradient(
                        stops: [
                            Gradient.Stop(color: .black, location: 0.00),
                            Gradient.Stop(color: Color(hex: "313037"), location: 1.00),
                        ],
                        startPoint: UnitPoint(x: 0.5, y: 0),
                        endPoint: UnitPoint(x: 0.5, y: 1.36)
                    )
                    )
                }
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(hex: "AD29FF"), location: 0.2),
                                .init(color: Color(hex: "3FE9FF"), location: 1)
                            ]),
                            startPoint: UnitPoint(x: 1 + sin(64 * .pi / 180), y: 1 - cos(64 * .pi / 180)),
                            endPoint: UnitPoint(x: 0, y: 0)
                        ), lineWidth: 1)
                )
            }
            
            VStack(spacing: 0) {
                Text("인원 선택")
                    .suit(.medium, size: 14)
                    .padding(.vertical, 8)
                
                Image("PlayerSettingBox")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 72)
                    .overlay(
                        HStack {
                            Image(systemName: "person.2.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25)
                            Text("\(playerCount)명")
                                .hakgyoansim(size: 20)
                        }
                    )
            }
            .frame(maxWidth: .infinity)
            .background(Color.ppDarkGray_02)
            .cornerRadius(10)
        }
    }
}

struct PlayerGridView: View {
    @Environment(GameData.self) var gameData

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 8) {
            ForEach(Array(gameData.players.enumerated()), id: \.element.id) { index, player in
                // 10번째일때만 중앙에 오게
                if index == 9 && gameData.players.count == 10 {
                    Spacer()
                    PlayerCellView(nickname: player.nickname ?? "")
                        .frame(width: 106, height: 32)
                    Spacer()
                } else {
                    PlayerCellView(nickname: player.nickname ?? "")
                        .frame(width: 106, height: 32)
                }
            }
        }
    }
}

struct PlayerCellView: View {
    let nickname: String
    
    var body: some View {
        VStack {
            Text(nickname)
                .suit(.medium, size: 14)
                .foregroundStyle(Color.ppDarkGray_01)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(hex: "121212"))
        .cornerRadius(10)
    }
}

#Preview {
    let gameData = GameData()
//    gameData.selectedAnime = Anime(id: "1", title: "주술 회전", quotes: [])
    gameData.selectedAnime = nil
    gameData.players = [
        Player(nickname: "안녕하세요를레히", turn: 1),
        Player(nickname: "플레이어 2", turn: 2),
        Player(nickname: "플레이어 3", turn: 3),
        Player(nickname: "플레이어 3", turn: 4),
        Player(nickname: "안녕하세요를레히", turn: 1),
        Player(nickname: "플레이어 2", turn: 2),
        Player(nickname: "플레이어 3", turn: 3),
        Player(nickname: "플레이어 3", turn: 4),
        Player(nickname: "안녕하세요를레히", turn: 1),
        Player(nickname: "안녕하세요를레히", turn: 1)
    ]
    
    let gameViewModel = GameViewModel()
    
    return HomeView()
        .environmentObject(Router())
        .environment(gameData)
        .environment(gameViewModel)
        .preferredColorScheme(.dark)
}

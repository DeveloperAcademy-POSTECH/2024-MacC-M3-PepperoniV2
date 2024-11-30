//
//  RankingView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI

struct RankingView: View {
    @EnvironmentObject var router: Router
    @Environment(GameViewModel.self) var gameViewModel
    
    @State var rankedPlayers: [Player] = []
    @State private var rowVisible: [Bool] = []
    @State var showAlert: Bool = false
    
    var body: some View {
        VStack {
            Header(
                title: "TOTAL RANKING",
                dismissAction: {
                    showAlert = true
                }
            )
            .padding(.vertical, 20)
            
            ScrollView {
                ForEach(rankedPlayers.indices, id: \.self) { index in
                    let player = rankedPlayers[index]
                    let isAboveHost = player.score > rankedPlayers.first(where: { $0.isHost })?.score ?? 0
                    
                    RankRow(player: player,
                            rank: index + 1,
                            isFirst: isAboveHost, // 호스트 보다 위인 사람은 first 효과
                            isLast: player.isHost, // host는 last 효과
                            isHost: player.isHost)
                        .opacity(rowVisible[index] ? 1 : 0) // 초기 상태는 보이지 않음
                        .offset(y: rowVisible[index] ? 0 : 20) // 약간 아래에서 올라오는 효과
                        .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.07), value: rowVisible[index])
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                                rowVisible[index] = true
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, (index == 0 || index == rankedPlayers.count - 2) ? 16 : 4)
                }
            }
            
            Spacer()
            
            ActionButtons(
                retryAction: {
                    gameViewModel.retryThisQuote()
                    gameViewModel.turnComplete = 0
                    router.pop(depth: 4)
                },
                exitAction: {
                    gameViewModel.turnComplete = 0
                    router.popToRoot()
                }
            )
        }
        .onAppear {
            rankedPlayers = gameViewModel.players.sorted { $0.score > $1.score }
            rowVisible = Array(repeating: false, count: rankedPlayers.count) // 초기화
        }
        .navigationBarBackButtonHidden(true)
    }
}


// MARK: - Rank Row Component
struct RankRow: View {
    let player: Player
    let rank: Int
    let isFirst: Bool
    let isLast: Bool
    let isHost: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(height: isFirst ? 80 : 70)
            .foregroundStyle(backgroundStyle)
            .overlay {
                ZStack {
                    if isFirst || isLast {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isLast ? lastPlaceStroke : firstPlaceStroke,
                                    lineWidth: isFirst || isLast ? 1 : 0.5)
                            .frame(height: isFirst ? 80 : 70)
                    }
                    HStack {
                        Text(rankText)
                            .hakgyoansim(size: isFirst ? 26 : 20)
                            .foregroundStyle(rankColor)
                        Spacer()
                        Text(player.nickname)
                            .suit(isFirst ? .bold : .medium, size: isFirst ? 22 : 18)
                            .foregroundStyle(nicknameColor)
                        Spacer()
                        Text("\(player.score / 3)점")
                            .hakgyoansim(size: isFirst ? 20 : 18)
                            .foregroundStyle(scoreColor)
                    }
                    .padding(.horizontal, isFirst ? 15 : 18)
                }
            }
            .shadow(color: .white.opacity(isLast ? 0.38 : 0), radius: 8.2, x: 0, y: 0)
        
    }
    
    private var backgroundStyle: AnyShapeStyle {
        if isLast {
                    return AnyShapeStyle(LinearGradient(
                        colors: [Color.black],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
        } else if isFirst {
            return AnyShapeStyle(firstPlaceGradient)
        } else {
            return AnyShapeStyle(LinearGradient(
                colors: [Color(hex: "37363B"), Color(hex: "19191B")],
                startPoint: .leading,
                endPoint: .trailing
            ))
        }
    }
    
    private var firstPlaceGradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(stops: [
                .init(color: Color(hex: "A52DEF"), location: 0.01),
                .init(color: Color(hex: "873FF2"), location: 0.19),
                .init(color: Color(hex: "6B56F4"), location: 0.36),
                .init(color: Color(hex: "4ADBFF"), location: 1.0)
            ]),
            center: UnitPoint(x: 0.52, y: -0.1),
            startRadius: 7,
            endRadius: 180
        )
    }
    
    private var firstPlaceStroke: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                Gradient.Stop(color: Color(hex: "FFD8F4"), location: 0.00),
                Gradient.Stop(color: Color(hex: "EA42BD"), location: 0.60),
                Gradient.Stop(color: Color(hex: "FFD8F4"), location: 0.78),
                Gradient.Stop(color: Color(hex: "904BDE"), location: 0.91)
            ]),
            startPoint: UnitPoint(x: 0.35, y: -0.1),
            endPoint: UnitPoint(x: 0.45, y: 1.2)
        )
    }
    
    private var lastPlaceStroke: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                Gradient.Stop(color: Color(hex: "A52DEF"), location: 0.01),
                Gradient.Stop(color: Color(hex: "873FF2"), location: 0.19),
                Gradient.Stop(color: Color(hex: "6B56F4"), location: 0.36),
                Gradient.Stop(color: Color(hex: "4ADBFF"), location: 1.0)
            ]),
            startPoint: UnitPoint(x: 0.52, y: -0.1),
            endPoint: UnitPoint(x: 0.45, y: 1.2)
        )
    }
    
    private var rankText: String {
        isLast ? "꼴찌" : "\(rank)위"
    }
    
    private var rankColor: Color {
        isFirst ? .white : (rank <= 3 ? Color.ppMint_00 : Color.ppBlueGray)
    }
    
    private var nicknameColor: Color {
        isFirst ? .white : Color.ppWhiteGray
    }
    
    private var scoreColor: Color {
        isFirst ? .white : Color.ppDarkGray_01
    }
}


// MARK: - Action Buttons Component
struct ActionButtons: View {
    let retryAction: () -> Void
    let exitAction: () -> Void
    
    var body: some View {
        VStack {
            Button(action: retryAction) {
                RoundedRectangle(cornerRadius: 60)
                    .frame(height: 54)
                    .foregroundStyle(Color.ppBlueGray)
                    .overlay {
                        Text("똑같은 대사로 한번더")
                            .suit(.extraBold, size: 16)
                            .foregroundStyle(Color.ppBlack_01)
                    }
            }
            .padding(.horizontal, 16)
            
            Button(action: exitAction) {
                Text("나가기")
                    .suit(.bold, size: 16)
                    .foregroundStyle(Color.ppWhiteGray)
            }
            .padding(18)
        }
    }
}



struct RankingView_Previews: PreviewProvider {
    static var previews: some View {
        // 샘플 데이터
        let samplePlayers = [
            Player(nickname: "Player1", turn:0, score: 300),
            Player(nickname: "Player2", turn:1, score: 297),
            Player(nickname: "Player3", turn:2, score: 273),
            Player(nickname: "Player4", turn:3, score: 130),
            Player(nickname: "Player1", turn:0, score: 100),
            Player(nickname: "Player2", turn:1, score: 0)
        ]
        
        // GameViewModel의 샘플 객체 생성
        let gameViewModel = GameViewModel()
        gameViewModel.players = samplePlayers
        
        // Router 샘플 객체 생성
        //        let router = Router()
        
        return RankingView()
        //            .environmentObject(router)
            .environment(gameViewModel)
            .preferredColorScheme(.dark)
    }
}

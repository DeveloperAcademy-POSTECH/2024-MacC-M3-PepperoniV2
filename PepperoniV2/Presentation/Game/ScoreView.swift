//
//  ScoreView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI

struct ScoreView: View {
    @EnvironmentObject var router: Router
    @Environment(GameViewModel.self) var gameViewModel
    @State var showAlert: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Header(
                    title: "",
                    dismissAction: {
                        showAlert = true
                    },
                    dismissButtonType: .text("나가기")
                )
                
                VStack{
                    TotalScore(gameViewModel: _gameViewModel)
                    
                    VStack {
                        HStack{
                            ScoreBar(score: gameViewModel.temporaryPronunciationScore)
                            ScoreBar(score: gameViewModel.temporaryIntonationScore)
                            ScoreBar(score: gameViewModel.temporarySpeedScore)
                        }
                        
                        ScoreTitle()
                    }
                    
                    // MARK: - 다음 플레이어 버튼
                    NextPlayerButton()
                }
                .padding(.top, 36)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("홈 화면으로 나가시겠습니까?"),
                    primaryButton: .destructive(Text("나가기")) {
                        router.popToRoot()
                    },
                    secondaryButton: .cancel(Text("취소"))
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}

struct TotalScore: View {
    @Environment(GameViewModel.self) var gameViewModel // ViewModel 가져오기
        
        var body: some View {
            VStack(spacing: 0) {
                Text("\(gameViewModel.players[gameViewModel.turnComplete].nickname ?? "") 결과")
                    .hakgyoansim(size: 20)
                    .padding(.bottom, 28)
                
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.ppDarkGray_02)
                    .frame(width: 121, height: 54)
                    .overlay(
                        HStack(spacing: 0) {
                            Text("총")
                            Text("\(Int((gameViewModel.temporaryPronunciationScore + gameViewModel.temporarySpeedScore + gameViewModel.temporaryIntonationScore) / 3))")
                                .foregroundStyle(Color.ppMint_00) // 숫자 색상 지정
                            Text("점")
                        }
                            .hakgyoansim(size: 30)
                        
                    )
                    .padding(.bottom, 50)
            }
        }
}

struct ScoreBar: View {
    @State private var animatedScore: Double = 0 // 애니메이션용 변수
    var score: Double
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                //TODO: - 0점일때는 가장 하단의 RoundedRectangle만 보여지게 해야함
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(Color.ppDarkGray_02)
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 74, height: animatedScore == 100 ? 370 * animatedScore / 100 : (370 * animatedScore / 100) + 2)
                    .foregroundStyle(.white)
                RoundedRectangle(cornerRadius: 14)
                    .frame(width: 70, height: 366 * animatedScore / 100)
                    .foregroundStyle(LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color.ppMint_00,location: 0.00),
                            Gradient.Stop(color: Color.ppPurple_02, location: 0.75),
                            Gradient.Stop(color: Color(hex:"AD29FF"), location: 1.00),
                        ],
                        startPoint: UnitPoint(x: 0.5, y: 0),
                        endPoint: UnitPoint(x: 0.5, y: 1)
                    ))
                    .shadow(color:.ppMint_00, radius: 15, y:-3)
                    .padding(.bottom, 2)
                Polygon()
                
            }
            .frame(width: 74, height: 370)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            .onAppear {
                // 애니메이션이 뷰가 나타날 때 발생
                withAnimation(.easeOut(duration: 1.0)) {
                    animatedScore = score
                }
            }
            
            HStack(spacing: 0) {
                Text(verbatim: "\(Int(score))")
                    .foregroundStyle(Color.ppMint_00)
                Text("점")
                    .foregroundStyle(Color.ppWhiteGray)
            }
            .hakgyoansim(size: 16)
        }
        .padding(.bottom, 12)
    }
    
    @ViewBuilder
    func Polygon() -> some View {
        GeometryReader { geometry in
            let maxHeight: CGFloat = 370 // ScoreBar 전체 높이
            let polygonHeight: CGFloat = 48 // Polygon의 높이
            let polygonTopHeight: CGFloat = 21 // PolygonTop의 높이
            let polygonWidth: CGFloat = 60 // 가로 너비
            let availableHeight = maxHeight - polygonTopHeight // PolygonTop을 제외한 사용 가능한 높이
            let totalPolygons = min(Int(animatedScore / 100 * (availableHeight / polygonHeight)), 7) // 배치할 폴리곤 개수
            
            ZStack {
                // Polygon 배치
                ForEach(0..<totalPolygons, id: \.self) { index in
                    Image("Polygon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: polygonWidth, height: polygonHeight)
                        .position(
                            x: geometry.size.width / 2,
                            y: maxHeight
                                - polygonHeight * CGFloat(index)
                                - polygonHeight / 2
                        )
                }

                // PolygonTop 배치 (100점일 때만 보임)
                if animatedScore == 100 {
                    Image("PolygonTop")
                        .resizable()
                        .scaledToFit()
                        .frame(width: polygonWidth, height: polygonTopHeight)
                        .position(
                            x: geometry.size.width / 2,
                            y: maxHeight - CGFloat(totalPolygons) * polygonHeight - polygonTopHeight / 2 // 마지막 Polygon 바로 위에 배치
                        )
                }
            }
        }
        .frame(height: 370) // ScoreBar 높이와 동일하게 설정
    }
}

struct ScoreTitle: View {
    var body: some View {
        ZStack {
            // RoundedRectangle 배경
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 309, height: 34)
                .foregroundStyle(Color.ppDarkGray_03)
            
            HStack() {
                Text("발음")
                    .padding(.leading, 33)
                Spacer()
                Text("억양")
                Spacer()
                Text("스피드")
                    .padding(.trailing, 24)
            }
            .frame(width: 309, height: 34, alignment: .center)
            .hakgyoansim(size: 16)
            .foregroundStyle(Color.ppWhiteGray)
            
        }
        .padding(.bottom, 30)
    }
}

//TODO: - 그라데이션 적용
struct NextPlayerButton: View {
    @Environment(GameViewModel.self) var gameViewModel // GameViewModel 접근
    @EnvironmentObject var router: Router // Router 접근

    var body: some View {
        Button {
            if gameViewModel.turnComplete < gameViewModel.players.count - 1 {
                DispatchQueue.main.async {
                    gameViewModel.players[gameViewModel.turnComplete].score = Int(
                        gameViewModel.temporaryPronunciationScore +
                        gameViewModel.temporaryIntonationScore +
                        gameViewModel.temporarySpeedScore
                    )
                    gameViewModel.turnComplete += 1
                    router.pop(depth: 1)
                }
            } else if gameViewModel.turnComplete == gameViewModel.players.count - 1 {
                DispatchQueue.main.async {
                    gameViewModel.players[gameViewModel.turnComplete].score = Int(
                        gameViewModel.temporaryPronunciationScore +
                        gameViewModel.temporaryIntonationScore +
                        gameViewModel.temporarySpeedScore
                    )
                    router.push(screen: Game.ranking)
                }
            }
        } label: {
            // 버튼 텍스트 설정
            HStack(spacing: 0) {
                if gameViewModel.turnComplete < gameViewModel.players.count - 1 {
                    Text("다음 ")
                        .suit(.extraBold, size: 16)
                        .foregroundStyle(Color.ppBlack_01)
                    
                    Text("\(gameViewModel.players[gameViewModel.turnComplete + 1].nickname ?? "")")
                        .suit(.extraBold, size: 16)
                        .foregroundStyle(Color.ppPurple_02) // 닉네임 부분 색상
                    
                    Text(" 시작")
                        .suit(.extraBold, size: 16)
                        .foregroundStyle(Color.ppBlack_01)
                } else {
                    Text("최종 순위 확인")
                        .suit(.bold, size: 16)
                        .foregroundStyle(.white) // 마지막 차례 텍스트 색상
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
        }
        .background(
            gameViewModel.turnComplete < gameViewModel.players.count - 1
                ? LinearGradient(
                    gradient: Gradient(colors: [Color.ppBlueGray]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                : LinearGradient(
                    gradient: Gradient(colors: [Color.ppMint_00,
                                                Color(hex:"AD29FF")]),
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
        )
        .cornerRadius(60)
        .padding(.horizontal)
        .padding(.bottom, 34)
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleGameViewModel = GameViewModel()
        sampleGameViewModel.players = [
            Player(nickname: "Player 1", turn: 1, score: 75),
            Player(nickname: "Player 2", turn: 2,score: 90)
        ]
        sampleGameViewModel.turnComplete = 0
        sampleGameViewModel.temporaryPronunciationScore = 80
        sampleGameViewModel.temporaryIntonationScore = 85
        sampleGameViewModel.temporarySpeedScore = 90
        
        return ScoreView()
            .environmentObject(Router())
            .environment(sampleGameViewModel)
            .preferredColorScheme(.dark)
    }
}

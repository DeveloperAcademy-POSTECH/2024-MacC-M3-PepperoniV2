//
//  SpeakingView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI

struct SpeakingView: View {
    @EnvironmentObject var router: Router
    @Environment(GameViewModel.self) var gameViewModel
    
    // TODO: - Preview용 gameviewmodel, 컬러 폰트 적용 후 삭제
    //    @State var gameViewModel: GameViewModel = GameViewModel(
    //        selectedAnime: Anime(
    //            id: "anime1",
    //            title: "진격의 거인",
    //            quotes: [
    //                AnimeQuote(
    //                    id: "quote1",
    //                    japanese: ["自由はあきらめない！"],
    //                    pronunciation: ["지유와 아키라메나이!"],
    //                    korean: ["자유를 포기하지 않아!"],
    //                    timeMark: [0.0, 1.0],
    //                    voicingTime: 2.0,
    //                    audioFile: "attack_on_titan_quote1.mp3",
    //                    youtubeID: "abcd1234",
    //                    youtubeStartTime: 12.5,
    //                    youtubeEndTime: 15.5
    //                ),
    //                AnimeQuote(
    //                    id: "quote2",
    //                    japanese: ["お前が決めるんだ！"],
    //                    pronunciation: ["오마에가 키메룬다!"],
    //                    korean: ["네가 결정하는 거야!"],
    //                    timeMark: [0.0, 1.5],
    //                    voicingTime: 2.5,
    //                    audioFile: "attack_on_titan_quote2.mp3",
    //                    youtubeID: "abcd1234",
    //                    youtubeStartTime: 20.0,
    //                    youtubeEndTime: 23.0
    //                )
    //            ]
    //        ),
    //        selectedQuote: AnimeQuote(
    //            id: "quote2",
    //            japanese: ["俺の","財宝か?","ほしけりゃ","くれてやる","さがせぃ!","この世の","全てを","そこに","おいてきた"],
    //            pronunciation: ["오레노","자이호오카","호시케랴","쿠레테야루","사가세","코노요노","스베테오","소코니","오이테키타"],
    //            korean: ["내","보물말이냐?","갖고싶다면","주지","찾아라","이세상의","모든 것을","그 곳에","두고 왔다"],
    //            timeMark: [0.1, 1.5, 1.8, 2.6, 2.9, 3.2, 3.5],
    //            voicingTime: 2.5,
    //            audioFile: "attack_on_titan_quote2.mp3",
    //            youtubeID: "abcd1234",
    //            youtubeStartTime: 20.0,
    //            youtubeEndTime: 23.0
    //        )
    //        ,
    //        players: [Player(nickname:"준요", turn: 0),
    //                  Player(nickname:"젠", turn: 1),
    //                  Player(nickname:"원", turn: 2),
    //                 ]
    //    )
    
    @State var isCounting: Bool = true
    @State var countdown = 3 // 초기 카운트 설정
    
    @State private var timer: Timer? = nil       // 타이머 객체
    @State private var timerCount: Double = 0.0 // 초기 타이머 설정 (초 단위)
    @State private var isRunning: Bool = false   // 타이머 상태
    @State private var pausedTime: Double? // 타이머 일시 중지 상태 저장
    
    @StateObject private var sttManager = STTManager()
    
    @State var showAlert: Bool = false
    
    @State private var playerOnTurn: Player?
    
    let maxWordsPerLine = 3 // 기본적으로 한 줄에 3단어까지
    let maxCharactersPerLine = 18 // 한 줄당 최대 글자 수
    @State var currentLine: [Int] = [] // 현재 줄에 포함된 단어 인덱스
    @State var lines: [[Int]] = [] // 나뉜 줄의 배열
    @State var currentCharCount = 0 // 현재 줄의 총 글자 수
    
    var body: some View {
        ZStack{
            VStack {
                Header(
                    title: "",
                    dismissAction: {
                        Task {
                            pauseTimer()
                            showAlert = true
                            await sttManager.pauseRecording() // 녹음 및 STT 일시 정지
                        }
                    },
                    dismissButtonType: .text("나가기")
                )
                .padding(.bottom, 14)
                
                Text("\(gameViewModel.players.count)명중 \(playerOnTurn?.turn ?? 0)번째")
                    .suit(.medium, size: 14)
                    .padding(.bottom, 6)
                
                Text("\(playerOnTurn?.nickname ?? "") 차례")
                    .hakgyoansim(size: 20)
                Spacer()
                
                ZStack{
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0), Color.ppDarkGray_03]),
                        startPoint: .top, // 대각선 시작점
                        endPoint: .bottom // 대각선 끝점
                    )
                    
                    // SwiftUI ViewBuilder에서 줄 나누기 결과를 표시
                    if let quote = gameViewModel.selectedQuote {
                        VStack(spacing: 16) { // 줄 간 간격
                            ForEach(lines.indices, id: \.self) { lineIndex in
                                HStack(spacing: 8) { // 단어 간 간격
                                    ForEach(lines[lineIndex], id: \.self) { index in
                                        WordCard(
                                            pronunciation: quote.pronunciation[index],
                                            japanese: quote.japanese[index],
                                            isHighlighted: isHighlighted(
                                                wordIndex: index,
                                                timeByWord: quote.timeMark,
                                                timerCount: timerCount
                                            )
                                        )
                                    }
                                }
                                .padding(.bottom, 20)
                            }
                        }
                        .padding()
                    }
                }
                .padding(.init(top: 50, leading: 0, bottom: 58, trailing: 0))
                Spacer()
                
                VStack{
                    Button(action:{
                        Task {
                            await sttManager.stopRecording()  // stopRecoding() 동기 처리
                            stopTimer()
                            grading()
                            router.push(screen: Game.score)
                        }
                    }, label:{
                        Image("SpeakingStopButton")
                            .resizable()
                            .frame(width:175, height:64)
                    })
                    .padding(.bottom, 40)
                }
            }
            
            if isCounting {
                Color.black // 어두운 오버레이 배경
                    .edgesIgnoringSafeArea(.all)
                
                VStack{
                    Text("\(gameViewModel.players.count)명중 \(playerOnTurn?.turn ?? 0)번째")
                        .suit(.medium, size: 14)
                        .padding(.bottom, 6)
                    
                    Text("\(playerOnTurn?.nickname ?? "") 차례")
                        .hakgyoansim(size: 20)
                        .padding(.bottom, 57)
                    ZStack{
                        Circle()
                            .frame(width:290, height:290)
                            .foregroundStyle(
                                EllipticalGradient(
                                    stops: [
                                        Gradient.Stop(color: Color(hex:"AD29FF"), location: 0.00),
                                        Gradient.Stop(color: Color(hex:"6652E7"), location: 0.36),
                                        Gradient.Stop(color: Color(hex:"3FE9FF"), location: 1.00),
                                    ],
                                    center: UnitPoint(x: 0.53, y: -0.04),
                                    startRadiusFraction: 0.1,
                                    endRadiusFraction: 1
                                )
                            )
                            .shadow(color: Color.ppMint_00, radius: 18.8, x: 0, y: -3)
                        Circle()
                            .frame(width:260, height:260)
                            .foregroundStyle(
                                LinearGradient(
                                    stops: [
                                        Gradient.Stop(color: Color(hex:"313037"), location: 0.12),
                                        Gradient.Stop(color: Color(hex:"0D0D0D"), location: 1.0),
                                    ],
                                    startPoint: UnitPoint(x: 0.0, y: 0.5),
                                    endPoint: UnitPoint(x: 1.0, y: 0.5)
                                )
                            )
                        if countdown > 0 {
                            Text("\(countdown)")
                                .hakgyoansim(size: 200)
                                .foregroundStyle(.white)
                        } else {
                            Text("START")
                                .hakgyoansim(size: 70)
                                .foregroundStyle(
                                    LinearGradient( //
                                        gradient: Gradient(stops: [
                                            Gradient.Stop(color: Color(hex: "AD29FF"), location: 0.06),
                                            Gradient.Stop(color: Color(hex: "FFFFFF"), location: 0.44),
                                            Gradient.Stop(color: Color(hex: "3FE9FF"), location: 1.0)
                                        ]),
                                        startPoint: .topTrailing,  // 대각선 시작점
                                        endPoint: .bottomLeading   // 대각선 끝점
                                    )
                                )
                                .shadow(color: Color.ppMint_00, radius: 8, x: 0, y: -3)
                        }
                    }
                    .frame(width:290, height:290)
                }
            } else {
                RoundedRectangle(cornerRadius: 60)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                Gradient.Stop(color: Color(hex: "3FE9FF"), location: 0.00),
                                Gradient.Stop(color: Color(hex: "6652E7"), location: 0.75),
                                Gradient.Stop(color: Color(hex: "AD29FF"), location: 1.0)
                            ]),
                            startPoint: .topLeading, // 시작점
                            endPoint: .bottomTrailing // 끝점
                        ),
                        lineWidth: 6 // 선의 굵기
                    )
                    .padding(2)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            startCountdown() // 뷰가 나타나면 카운트다운 시작
            for player in gameViewModel.players {
                if player.turn == gameViewModel.turnComplete + 1 {
                    playerOnTurn = player
                }
            }
            
            currentLine = []
            lines = []
            currentCharCount = 0
            
            // 단어를 순회하면서 줄을 나누기 (Swift의 일반 for문 사용)
            if let quote = gameViewModel.selectedQuote {
                for (index, word) in quote.japanese.enumerated() {
                    let wordLength = word.count
                    if currentCharCount + wordLength <= maxCharactersPerLine && currentLine.count < maxWordsPerLine {
                        currentLine.append(index)
                        currentCharCount += wordLength
                    } else {
                        lines.append(currentLine)
                        currentLine = [index]
                        currentCharCount = wordLength
                    }
                }
                if !currentLine.isEmpty {
                    lines.append(currentLine)
                }
            }
        }
        .onDisappear {
            isCounting = true
            countdown = 3
        }
        .onChange(of: isCounting) {
            if isCounting == false {
                startTimer()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("홈 화면으로 나가시겠습니까?"),
                primaryButton: .destructive(Text("나가기")) {
                    Task {
                        // Alert를 닫고 비동기로 작업 수행
                        await sttManager.stopRecording() // 녹음과 STT 중단
                        gameViewModel.turnComplete = 0
                        router.popToRoot()
                    }
                },
                secondaryButton: .cancel(Text("취소")) {
                    Task {
                        // Alert를 닫고 녹음 재개
                        resumeTimer()
                        await sttManager.resumeRecording()
                    }
                }
            )
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else if countdown == 1 {
                countdown -= 1
                
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.7) {
                    self.isCounting = false
                    timer.invalidate()
                    sttManager.startRecording() // STT 녹음 시작
                }
            }
        }
    }
    
    // 0에서 증가하는 타이머 시작 함수
    private func startTimer() {
        if isRunning { return } // 이미 타이머가 실행 중이면 종료
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            timerCount += 0.01
        }
    }
    
    private func stopTimer() {
        self.timer?.invalidate()  // 타이머 중지
        self.timer = nil          // 타이머 객체 초기화
        timerCount = 0
        isRunning = false
    }
    
    private func pauseTimer() {
        guard isRunning else { return } // 실행 중일 때만 작동
        pausedTime = timerCount // 현재 시간을 저장
        timer?.invalidate() // 타이머 정지
        timer = nil
        isRunning = false
        print("Timer paused at: \(pausedTime ?? 0)")
    }

    // 타이머 재개 함수
    private func resumeTimer() {
        guard let pausedTime = pausedTime, !isRunning else { return } // 일시 중지된 상태여야 함
        timerCount = pausedTime // 일시 중지된 시간으로 복원
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            self.timerCount += 0.01
        }
        print("Timer resumed from: \(pausedTime)")
    }
    
    private func isHighlighted(wordIndex: Int, timeByWord: [Double], timerCount: Double) -> Bool {
        guard wordIndex < timeByWord.count else { return false } // 마지막 단어 보호
        
        let startTime = timeByWord[wordIndex]
        return timerCount >= startTime
    }
    
    /// 채점 함수
    /// 사용자 음성의 발음, 억양, 스피드를 대상 음성과 비교하여 채점합니다.
    private func grading() {
        // 발음과 속도를 채점합니다.
        print("채점시작) 사용자 일본어: \(sttManager.recognizedText)")
        if let quote = gameViewModel.selectedQuote{
            gameViewModel.temporaryPronunciationScore = calculatePronunciation(original: quote.japanese, sttText: sttManager.recognizedText)
            
            gameViewModel.temporaryIntonationScore = calculateIntonation(referenceFileName: quote.audioFile, comparisonFileURL: sttManager.getFileURL())
            print("레퍼런스 음원 주소: \(quote.audioFile)")
            print("사용자 목소리 음원 주소: \(sttManager.getFileURL())")
            
            if let sttVoicingTime = sttManager.voicingTime {
                gameViewModel.temporarySpeedScore = calculateVoiceSpeed(originalLength: quote.voicingTime, sttVoicingTime: sttVoicingTime)
                print("사용자 STT 음성 속도: \(sttVoicingTime)")
            } else {
                print("Error: sttManager.voicingTime is nil.")
            }
        }
    }
}

//#Preview {
//    SpeakingView()
//        .preferredColorScheme(.dark)
//}

struct WordCard: View {
    let pronunciation: String
    let japanese: String
    let isHighlighted: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Text(pronunciation)
                .suit(.bold, size: 18)
                .foregroundStyle(isHighlighted ? Color.black : Color.ppMint_00)
            Text(japanese)
                .foregroundStyle(isHighlighted ? Color.ppPurple_02 : Color.ppWhiteGray)
        }
        .bold()
        .padding(8)
        .background(
            Group {
                if isHighlighted {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.ppMint_00)
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .foregroundStyle(Color.ppDarkGray_02)
                }
            }
            .frame(height: 88) // frame을 Group에 적용
        )
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

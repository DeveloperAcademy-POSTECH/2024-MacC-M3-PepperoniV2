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
//            japanese: ["お前が決！", "めるんだ"],
//            pronunciation: ["오마에가", "키메룬다!"],
//            korean: ["네가 결정하는", "거야!"],
//            timeMark: [0.0, 1.5],
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
    
    @StateObject private var sttManager = STTManager()
    
    @State var showAlert: Bool = false
    
    var body: some View {
        ZStack{
            VStack {
                Header(
                    title: "",
                    dismissAction: {
                        showAlert = true
                    },
                    dismissButtonType: .text("나가기")
                )
                .padding(.bottom, 14)
                
                Text("\(gameViewModel.players.count)명중 \(gameViewModel.players[gameViewModel.turnComplete].turn+1)번째")
                    .font(.system(size: 14))
                    .padding(.bottom, 6)
                
                Text("\(gameViewModel.players[gameViewModel.turnComplete].nickname ?? "") 차례")
                    .font(.system(size: 20))
                    .padding(.bottom, 38)
                
                Rectangle()
                    .frame(height:1)
                    .foregroundStyle(.gray)
                    .padding(.horizontal, 17.5)
                
                Spacer()
                
                if let quote = gameViewModel.selectedQuote{
                    if quote.japanese.count >= 5 {
                        let halfIndex = quote.japanese.count / 2
                        
                        // 두 개의 HStack으로 나누어 텍스트 표시
                        VStack {
                            HStack {
                                ForEach(0..<halfIndex, id: \.self) { index in
                                    WordCard(
                                        pronunciation: quote.pronunciation[index],
                                        japanese: quote.japanese[index],
                                        isHighlighted: isHighlighted(wordIndex: index, timeByWord: quote.timeMark, timerCount: timerCount)
                                    )
                                }
                            }
                            .padding()
                            
                            HStack {
                                ForEach(halfIndex..<quote.japanese.count, id: \.self) { index in
                                    WordCard(
                                        pronunciation: quote.pronunciation[index],
                                        japanese: quote.japanese[index],
                                        isHighlighted: isHighlighted(wordIndex: index, timeByWord: quote.timeMark, timerCount: timerCount)
                                    )
                                }
                            }
                            .padding(.bottom, 50)
                        }
                        
                    } else {
                        // 길이가 5 미만일 때 기존 방식
                        HStack {
                            ForEach(quote.japanese.indices, id: \.self) { index in
                                WordCard(
                                    pronunciation: quote.pronunciation[index],
                                    japanese: quote.japanese[index],
                                    isHighlighted: isHighlighted(wordIndex: index, timeByWord: quote.timeMark, timerCount: timerCount)
                                )
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
                
                Rectangle()
                    .frame(height:1)
                    .foregroundStyle(.gray)
                    .padding(.init(top: 0, leading: 17.5, bottom: 65, trailing: 17.5))
                
                VStack{
                    Button(action:{
                        Task {
//                            await sttManager.stopRecording()  // stopRecoding() 동기 처리
                            stopTimer()
                            grading()
//                            router.push(screen: Game.score)
                        }
                    }, label:{
                        Image("SpeakingStopButton")
                            .resizable()
                            .frame(width:175, height:64)
                    })
                    .padding(.bottom, 78)
                }
                
            }
            if !isCounting {
                RoundedRectangle(cornerRadius: 60)
                    .stroke(
                            LinearGradient(
                                colors: [.blue, .green, .purple], // 그라데이션 색상
                                startPoint: .topLeading,         // 시작점
                                endPoint: .bottomTrailing        // 끝점
                            ),
                            lineWidth: 6 // 선의 굵기
                        )
                    
                    .padding(2)
                    .ignoresSafeArea()
                    
            }
            if isCounting {
                Color.black.opacity(0.7) // 어두운 오버레이 배경
                    .edgesIgnoringSafeArea(.all)
                
                Text(countdown > 0 ? "\(countdown)" : "Start!")
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        
        .onAppear {
            startCountdown() // 뷰가 나타나면 카운트다운 시작
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
                    router.popToRoot()
                },
                secondaryButton: .cancel(Text("취소"))
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                .font(.system(size: 18))
            Text(japanese)
                .font(.system(size: 14))
        }
        .bold()
        .padding(8)
        .background(
            isHighlighted
            ? RoundedRectangle(cornerRadius: 4)
                .fill(Color.blue.opacity(0.5))
                .frame(height: 88)
            : nil
        )
    }
}

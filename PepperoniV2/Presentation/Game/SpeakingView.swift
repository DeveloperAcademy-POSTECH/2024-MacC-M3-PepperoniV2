//
//  SpeakingView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI

struct SpeakingView: View {
    @EnvironmentObject var router: Router
    
    // 2줄 더미데이터
    let quote: AnimeQuote = AnimeQuote(id: "String",
                                       japanese: ["本当の", "夢は", "その", "先に", "あるんだけど", "어쩌구저쩌"],
                                       pronunciation: ["혼토오노", "유메와", "소노", "사키니", "아룬다케도", "어쩌구저쩌"],
                                       korean: ["진짜", "꿈은", "그", "뒤에", "있어", "어쩌구저쩌"],
                                       timeMark: [0.01, 0.5, 1.1, 1.3, 1.7, 2.2],
                                       voicingTime: 2.2,
                                       audioFile: "BOT006.m4a",
                                       youtubeID: "6gQGHGpoBm4",
                                       youtubeStartTime: 1,
                                       youtubeEndTime: 26)
    // 1줄 더미데이터
    //    let quote: AnimeQuote = AnimeQuote(id: "String",
    //                                       japanese: ["本当の", "夢は", "その", "先に"],
    //                                       pronunciation: ["혼토오노", "유메와", "소노", "사키니"],
    //                                       korean: ["진짜", "꿈은", "그", "뒤에"],
    //                                       timeMark: [0.01, 0.5, 1.1, 1.3],
    //                                       voicingTime: 1.7,
    //                                       audioFile: "BOT006.m4a",
    //                                       youtubeID: "6gQGHGpoBm4",
    //                                       youtubeStartTime: 1,
    //                                       youtubeEndTime: 26)
    
    @State var isCounting: Bool = true
    @State var countdown = 3 // 초기 카운트 설정
    
    @State private var timer: Timer? = nil       // 타이머 객체
    @State private var timerCount: Double = 0.0 // 초기 타이머 설정 (초 단위)
    @State private var isRunning: Bool = false   // 타이머 상태
    
    @State private var temporaryPronunciationScore: Double = 0.0
    @State private var temporarySpeedScore: Double = 0.0
    @State private var temporaryIntonationScore: Double = 0.0
    
    var body: some View {
        ZStack{
            VStack {
                Spacer()
                
                Text("10명중 1번쨰")
                    .font(.system(size: 14))
                    .padding(.bottom, 6)
                
                Text("강우원 차례입니다.")
                    .font(.system(size: 20))
                
                Spacer()
                
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
                        .padding()
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
                Spacer()
                VStack{
                    Button(action:{
                        Task {
                            //                        await sttManager.stopRecording()  // stopRecoding() 동기 처리
                            router.push(screen: Game.score)
                            stopTimer()
                            //                        grading()
                            //                        navigateToResult = true
                        }
                    }, label:{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 280, height: 64) // Circle의 크기 지정
                            .overlay(
                                Text("STOP")
                                    .foregroundStyle(.white)
                                    .bold()
                            )
                    })
                    .padding(.bottom, 78)
                }
                
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
                    //                    sttManager.startRecording() // STT 녹음 시작
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
    
}

#Preview {
    SpeakingView()
}

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
                ? RoundedRectangle(cornerRadius: 8)
                    .fill(Color.yellow.opacity(0.5))
                    .frame(height: 88)
                : nil
        )
    }
}

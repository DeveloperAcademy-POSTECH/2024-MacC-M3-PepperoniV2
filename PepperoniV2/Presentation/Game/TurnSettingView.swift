//
//  TurnSettingView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI
import AVFoundation
import Speech

struct TurnSettingView: View {
    @EnvironmentObject var router: Router
    @Environment(GameViewModel.self) var gameViewModel
    
    @StateObject var manager: RouletteManager = RouletteManager(players: [
        Player(nickname: "준요", turn: 1),
        Player(nickname: "젠", turn: 2),
        Player(nickname: "원", turn: 3),
        Player(nickname: "하래", turn: 4),
        Player(nickname: "자운드", turn: 5),
        Player(nickname: "푸딩", turn: 6),
        Player(nickname: "준요", turn: 1),
        Player(nickname: "젠", turn: 2),
        Player(nickname: "원", turn: 3),
        Player(nickname: "하래", turn: 4),
    ])
    
    @State private var showAlert = false
    @State private var afterRoulette = false
    
    var body: some View {
        VStack {
            Header(
                title: "첫 순서 룰렛",
                dismissAction: {
                    showAlert = true
                },
                dismissButtonType: .text("나가기")
            )
            Spacer()
            
            Text("First Turn")
                .font(.system(size: 20, weight: .bold)) // 텍스트 스타일 지정
                .foregroundColor(.clear) // 텍스트 색상을 투명으로 설정
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.ppMint_00, Color(hex: "AD29FF", opacity: 1.0)]),
                        startPoint: .bottomLeading, // 대각선 시작점
                        endPoint: .topTrailing // 대각선 끝점
                    )
                )
                .mask(
                    Text("First Turn")
                        .font(.system(size: 20, weight: .bold)) // 동일한 텍스트 스타일 적용
                )
            
            ZStack {
                Circle()
                    .fill(.clear)
                    .frame(width: 300, height: 300)
                    .overlay(
                        ZStack {
                            ForEach(manager.players.indices, id:\.self) { index in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .frame(width: 100, height: 30)
                                        .foregroundStyle(Color.ppDarkGray_03)
                                    Text(manager.players[index].nickname ?? "")
                                        .suit(.bold, size:12)
                                }
                                .offset(y: -170)
                                .rotationEffect(.degrees(Double(index) * manager.sectorAngle))
                            }
                        }
                    )
                    .rotationEffect(.degrees(manager.rotation))
                    .animation(.easeOut(duration: manager.isSpinning ? 3 : 0), value: manager.rotation)
                RoundedRectangle(cornerRadius: 6)
                    .stroke(
                        RadialGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(hex:"A52DEF"), location: 0.01),
                                .init(color: Color(hex:"873FF2"), location: 0.19),
                                .init(color: Color(hex:"6B56F4"), location: 0.36),
                                .init(color: Color(hex:"4ADBFF"), location: 1.0)
                            ]),
                            center: UnitPoint(x: 0.52, y: -0.1),
                            startRadius: 7,
                            endRadius: 180
                        ),
                        lineWidth: 1
                    )
                    .frame(width: 100, height: 30)
                    .offset(y:-170)
            }
            .padding(.init(top: 40, leading: 0, bottom: 50, trailing: 0))
            Spacer()
            if !afterRoulette {
                HStack{
                    Button(action:{
                        manager.spinRoulette()
                        afterRoulette = true
                    }, label:{
                        RoundedRectangle(cornerRadius: 60)
                            .frame(height:54)
                            .foregroundStyle(
                                RadialGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color(hex:"A52DEF"), location: 0.01),
                                        .init(color: Color(hex:"9C34F0"), location: 0.06),
                                        .init(color: Color(hex:"6B56F4"), location: 0.36),
                                        .init(color: Color(hex:"4ADBFF"), location: 1.0)
                                    ]),
                                    center: UnitPoint(x: 0.62, y: -0.39),
                                    startRadius: -30,
                                    endRadius: 180
                                )
                            )
                            .overlay{
                                Text("순서 룰렛 돌리기")
                                    .suit(.extraBold, size: 16)
                                    .foregroundStyle(.white)
                            }
                            .padding(.init(top: 0, leading: 16, bottom: 0, trailing: 12))
                    })
                    Button {
                        router.push(screen: Game.videoPlay)
                    } label: {
                        RoundedRectangle(cornerRadius: 60)
                            .frame(width:90, height:54)
                            .foregroundStyle(Color.ppBlueGray)
                            .overlay{
                                Text("SKIP")
                                    .hakgyoansim(size: 16)
                                    .foregroundStyle(.black)
                            }
                            .padding(.trailing, 16)
                    }
                }
                .padding(.bottom, 10)
            } else{
                Button(action:{
                    router.push(screen: Game.videoPlay)
                    if let firstPlayer = manager.selectedItem{
                        gameViewModel.changeTurn(first: firstPlayer)
                    }
                }, label:{
                    RoundedRectangle(cornerRadius: 60)
                        .frame(height:54)
                        .foregroundStyle(Color.ppBlueGray)
                        .overlay{
                            Text("다음")
                                .suit(.extraBold, size:16)
                                .foregroundStyle(Color.ppBlack_01)
                        }
                        .padding(.init(top: 0, leading: 16, bottom: 10, trailing: 16))
                })
                
            }
        }
        
        .onAppear {
            manager.players = gameViewModel.players
            afterRoulette = false
        }
        .onAppear{
            // 마이크 권한 요청
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    print("마이크 접근 권한이 허용되었습니다.")
                    
                    // 음성 인식 권한 요청
                    // TODO: Speech 권한 허용 위해 Speech를 추가, 구조 분리-변경 필요
                    // TODO: 사용자가 권한 거부할 경우 권한 켜도록 유도 필요(온보딩 만들어주기 or 거부했을 경우 설정에서 켜게 하기)
                    SFSpeechRecognizer.requestAuthorization { authStatus in
                        DispatchQueue.main.async {
                            switch authStatus {
                            case .authorized:
                                print("음성 인식 권한이 허용되었습니다.")
                            case .denied:
                                print("음성 인식 권한이 거부되었습니다.")
                            case .restricted:
                                print("음성 인식이 제한되었습니다.")
                            case .notDetermined:
                                print("음성 인식 권한이 설정되지 않았습니다.")
                            @unknown default:
                                break
                            }
                        }
                    }
                    
                } else {
                    print("마이크 접근 권한이 거부되었습니다.")
                }
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
}

#Preview{
    TurnSettingView()
        .preferredColorScheme(.dark)
}

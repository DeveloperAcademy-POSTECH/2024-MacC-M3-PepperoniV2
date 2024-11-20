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
    
    @StateObject var manager: RouletteManager = RouletteManager(players: [])
    
    var body: some View {
        VStack {
            RouletteTriangle()
                .fill(Color.black)
                .frame(width: 20, height: 40)
                .padding(20)
            
            ZStack {
                Circle()
                    .fill(.clear)
                    .frame(width: 300, height: 300)
                    .overlay(
                        ZStack {
                            ForEach(manager.players.indices, id:\.self) { index in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(style: StrokeStyle(lineWidth: 2))
                                        .frame(width: 100, height: 50)
                                    Text(manager.players[index].nickname ?? "")
                                }
                                .offset(y: -150)
                                .rotationEffect(.degrees(Double(index) * manager.sectorAngle))
                            }
                        }
                    )
                    .rotationEffect(.degrees(manager.rotation))
                    .animation(.easeOut(duration: manager.isSpinning ? 3 : 0), value: manager.rotation)
            }
            .onTapGesture {
                manager.spinRoulette()
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
        }
        Button {
            router.push(screen: Game.videoPlay)
            if let firstPlayer = manager.selectedItem{
                gameViewModel.changeTurn(first: firstPlayer)
            }
        } label: {
            Text("다음")
        }
        .onAppear {
            manager.players = gameViewModel.players
        }
    }
}

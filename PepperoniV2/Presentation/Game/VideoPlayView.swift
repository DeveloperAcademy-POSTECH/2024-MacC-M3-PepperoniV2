//
//  VideoPlayView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI
import AVKit

struct VideoPlayView: View {
    
    @EnvironmentObject var router: Router
    @Environment(GameViewModel.self) var gameViewModel
    
    @State private var replayTrigger = false
    @State private var showAlert = false
    
    @State private var playerOnTurn: Player?
    
    var body: some View {
        VStack{
            Header(
                title: "플레이 참고영상",
                dismissAction: {
                    showAlert = true
                },
                dismissButtonType: .text("나가기")
            )
            .padding(.bottom, 34)
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.ppDarkGray_02, lineWidth: 2)
                .frame(height: 78)
                .overlay{
                    VStack(spacing:6){
                        HStack{
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("주의")
                                .hakgyoansim(size: 16)
                                .foregroundStyle(Color.ppWhiteGray)
                        }
                        Text("애니 내용 스포가 포함되어 있습니다.")
                            .suit(.medium, size:16)
                            .foregroundStyle(Color.ppDarkGray_01)
                    }
                }
                .padding(.init(top: 0, leading: 36, bottom: 28, trailing: 36))
            
            VStack(spacing: 0){
                Rectangle()
                    .frame(height: 52)
                    .foregroundStyle(Color.ppDarkGray_03)
                    .overlay{
                        Text("\"\(gameViewModel.selectedQuote?.korean.joined(separator: " ") ?? "")\"")
                            .hakgyoansim(size: 18)
                            .foregroundStyle(Color.ppMint_00)
                    }
                
                if let selectedQuote = gameViewModel.selectedQuote {
                    if let fileURL = Bundle.main.url(forResource: selectedQuote.audioFile, withExtension: "mov") {
                        VideoPlayer(player: AVPlayer(url: fileURL))
                            .frame(height: 218)
                            .padding(.bottom, 24)
                    }  else {
                        Text("영상 파일을 로드할 수 없습니다.")
                            .foregroundColor(.red)
                    }
                }
            }
            
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.ppDarkGray_02, lineWidth: 2)
                .frame(height: 50)
                .overlay{
                        Text("참고용 영상 안의 대사를 따라 말할 예정입니다.")
                        .suit(.medium, size: 16)
                            .foregroundStyle(Color.ppDarkGray_01)
                }
                .padding(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
            
            Spacer()
            
            Button(action: {
                replayTrigger.toggle()
                print("다시누름: \(gameViewModel.selectedQuote?.audioFile)")
            }) {
                RoundedRectangle(cornerRadius: 50)
                    .frame(width:109, height:41)
                    .foregroundStyle(Color.ppDarkGray_03)
                    .overlay{
                        HStack(spacing:4){
                            Image(systemName:"arrow.counterclockwise")
                            Text("replay")
                                .hakgyoansim(size: 19)
                        }
                        .foregroundStyle(Color.ppMint_00)
                    }
                    .padding(.bottom, 12)
            }
        
            Button {
                router.push(screen: Game.speaking)
            } label: {
                RoundedRectangle(cornerRadius: 60)
                    .foregroundStyle(
                        RadialGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(hex:"A52DEF"), location: 0.01),
                                .init(color: Color(hex:"6B56F4"), location: 0.36),
                                .init(color: Color(hex:"4ADBFF"), location: 1.0)
                            ]),
                            center: UnitPoint(x: 0.5, y: 0.5),
                            startRadius: 5,
                            endRadius: 180
                        )
                    )
                    .frame(height:54)
                    .overlay{
                        let nowPlayer = gameViewModel.players.filter{ $0.turn == gameViewModel.turnComplete+1}.first
                        Text("\(nowPlayer?.nickname ?? "") 차례 시작")
                            .suit(.extraBold, size: 16)
                            .foregroundStyle(Color.ppWhiteGray)
                    }
                    .padding(.horizontal, 16)
            }
        }
        .onAppear{
            for player in gameViewModel.players {
                if player.turn == gameViewModel.turnComplete + 1 {
                    playerOnTurn = player
                }
            }
            print("\(gameViewModel.selectedQuote?.korean)")
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

//
//  VideoPlayView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI

struct VideoPlayView: View {
    @EnvironmentObject var router: Router
    @Environment(GameViewModel.self) var gameViewModel
    
    @State private var replayTrigger = false
    @State private var showAlert = false
    
    var body: some View {
        VStack{
            Header(
                title: "애니 선택",
                dismissAction: {
                    showAlert = true
                },
                dismissButtonType: .text("나가기")
            )
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
                .frame(height: 78)
                .overlay{
                    VStack(spacing:6){
                        HStack{
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("주의")
                        }
                        Text("애니 내용 스포가 포함되어 있습니다.")
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.init(top: 0, leading: 36, bottom: 28, trailing: 36))
            
            if let selectedQuote = gameViewModel.selectedQuote{
                YouTubePlayerView(
                    videoID: selectedQuote.youtubeID,
                    startTime: Int(selectedQuote.youtubeStartTime),
                    endTime: Int(selectedQuote.youtubeEndTime),
                    replayTrigger: replayTrigger
                )
                .frame(height: 218)
                .padding(.bottom, 24)
            }
            
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
                .frame(height: 50)
                .overlay{
                    VStack(spacing:6){
                        Text("참고용 영상 안의 대사를 따라 말할 예정입니다.")
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.init(top: 0, leading: 16, bottom: 131, trailing: 16))
            
            Button(action: {
                replayTrigger.toggle()
            }) {
                Image("YoutubeReplayButton")
                    .resizable()
                    .frame(width:109, height:41)
                    .padding(.bottom, 28)
            }
            
            Button {
                router.push(screen: Game.speaking)
            } label: {
                RoundedRectangle(cornerRadius: 60)
                    .frame(height:54)
                    .overlay{
                        Text("젠데이아 첫번째 시작")
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 16)
                
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

//#Preview {
//    VideoPlayView()
//        .preferredColorScheme(.dark)
//}

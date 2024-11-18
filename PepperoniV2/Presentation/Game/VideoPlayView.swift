//
//  VideoPlayView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI

struct VideoPlayView: View {
    @EnvironmentObject var router: Router
    
    // TODO: 유튜브 속성 임의로 설정 - 추후 삭제
    @State private var youtubeID = "Ue_JMHDEds4"
    @State private var youtubeStartTime = 40
    @State private var youtubeEndTime = 50
    
    @State private var replayTrigger = false
    
    
    var body: some View {
        YouTubePlayerView(
            videoID: youtubeID,
            startTime: youtubeStartTime,
            endTime: youtubeEndTime,
            replayTrigger: replayTrigger
        )
        .frame(height: 218)
        .padding(.bottom, 24)
        
        Button(action: {
            replayTrigger.toggle()
        }) {
            Text("Replay")
        }
        
        Button {
            router.push(screen: Game.speaking)
        } label: {
            Text("다음")
        }
    }
}

#Preview {
    VideoPlayView()
}

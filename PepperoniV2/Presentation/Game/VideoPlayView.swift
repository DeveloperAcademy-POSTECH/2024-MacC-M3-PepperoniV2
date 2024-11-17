//
//  VideoPlayView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI

struct VideoPlayView: View {
    @EnvironmentObject var router: Router
    
    @State private var youtubeID = "Ue_JMHDEds4"
    @State private var youtubeStartTime = 40
    @State private var youtubeEndTime = 50
    
    
    var body: some View {
        YouTubePlayerView(videoID: youtubeID, startTime: youtubeStartTime, endTime: youtubeEndTime)
            .frame(height: 218)
            .padding(.bottom, 24)
        
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

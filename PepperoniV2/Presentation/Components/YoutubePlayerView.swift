//
//  YoutubePlayerView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/18/24.
//

import SwiftUI
import YouTubeiOSPlayerHelper

struct YouTubePlayerView: UIViewRepresentable {
    var videoID: String
    var startTime: Int
    var endTime: Int
    var replayTrigger: Bool
    
    func makeUIView(context: Context) -> YTPlayerView {
        let playerView = YTPlayerView()
        
        let playerVars: [String: Any] = [
            "playsinline": 1,
            "autoplay": 0,
            "rel": 0,
            "start": startTime,
            "end": endTime
        ]

        playerView.load(withVideoId: videoID, playerVars: playerVars)
        return playerView
    }

    func updateUIView(_ uiView: YTPlayerView, context: Context) {
        if replayTrigger {
            uiView.seek(toSeconds: Float(startTime), allowSeekAhead: true)
        }
    }
}



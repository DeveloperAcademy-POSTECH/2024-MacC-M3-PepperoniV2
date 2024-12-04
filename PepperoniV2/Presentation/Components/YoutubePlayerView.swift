//
//  YoutubePlayerView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/18/24.
//

import SwiftUI
import AVKit

import SwiftUI
import AVKit

struct YouTubePlayerView: UIViewControllerRepresentable {
    var fileURL: URL
    var replayTrigger: Bool

    class Coordinator {
        var parent: YouTubePlayerView

        init(parent: YouTubePlayerView) {
            self.parent = parent
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        let player = AVPlayer(url: fileURL)
        playerViewController.player = player
        playerViewController.showsPlaybackControls = true

        return playerViewController
    }

    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
        guard let player = playerViewController.player else { return }

        if replayTrigger {
            // 재생 중지 후 처음부터 재생
            player.seek(to: .zero)
            player.play()
        }
    }
}



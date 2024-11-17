//
//  Game.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI

public enum Game: Hashable {
    case turnSetting
    case videoPlay
    case speaking
    case score
    case ranking
}

struct GameView: View {
    let type: Game
    
    var body: some View {
        if type == .turnSetting {
            TurnSettingView()
        } else if type == .videoPlay {
            VideoPlayView()
        } else if type == .speaking {
            SpeakingView()
        } else if type == .score {
            ScoreView()
        } else if type == .ranking {
            RankingView()
        }
    }
}

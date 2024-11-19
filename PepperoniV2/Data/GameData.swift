//
//  GameData.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/18/24.
//

import SwiftUI

struct Player {
    var nickname: String?
    var turn: Int
    var score: Int = 0
}

@Observable class GameData {
    var selectedAnime: Anime?
    var selectedQuote: AnimeQuote?
    var players: [Player] = [Player(nickname: "1번", turn: 1)]
}

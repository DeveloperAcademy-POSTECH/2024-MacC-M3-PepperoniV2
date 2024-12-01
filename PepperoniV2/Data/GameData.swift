//
//  GameData.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/18/24.
//

import SwiftUI

struct Player: Identifiable {
    let id: UUID = UUID() 
    var nickname: String = ""
    var turn: Int
    var score: Int = 0
    var isHost = false
}

@Observable class GameData {
    var selectedAnime: Anime?
    var selectedQuote: AnimeQuote?
    var players: [Player] = [Player(turn: 1, isHost: true), Player(turn: 2)]
}

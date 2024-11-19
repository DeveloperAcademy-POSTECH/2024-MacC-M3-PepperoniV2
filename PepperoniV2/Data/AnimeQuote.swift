//
//  AnimeQuote.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/16/24.
//

import SwiftData
import Foundation

@Model
class Anime {
    @Attribute(.unique) var id: String
    var title: String
    @Relationship(deleteRule: .cascade) var quotes: [AnimeQuote]

    init(id: String, title: String, quotes: [AnimeQuote] = []) {
        self.id = id
        self.title = title
        self.quotes = quotes
    }
}

@Model
class AnimeQuote {
    @Attribute(.unique) var id: String
    var japanese: [String] // 원문 대사
    var pronunciation: [String] // 발음 정보
    var korean: [String] // 한국어 번역
    var timeMark: [Double] // 각 단어가 시작되는 타임마크
    var voicingTime: Double // 말하기 Speed 채점을 위한 기준
    var audioFile: String // 음성 파일 로컬 경로
    var youtubeID: String // 유튜브 영상 ID
    var youtubeStartTime: Double // 유튜브 영상 시작 시간
    var youtubeEndTime: Double // 유튜브 영상 끝 시간

    init(id: String, japanese: [String], pronunciation: [String], korean: [String], timeMark: [Double], voicingTime: Double, audioFile: String, youtubeID: String, youtubeStartTime: Double, youtubeEndTime: Double) {
        self.id = id
        self.japanese = japanese
        self.pronunciation = pronunciation
        self.korean = korean
        self.timeMark = timeMark
        self.voicingTime = voicingTime
        self.audioFile = audioFile
        self.youtubeID = youtubeID
        self.youtubeStartTime = youtubeStartTime
        self.youtubeEndTime = youtubeEndTime
    }
}

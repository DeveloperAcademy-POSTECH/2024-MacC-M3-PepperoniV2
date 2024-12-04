//
//  AnimeQuote.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/16/24.
//

import SwiftData

// TODO: 임시로 넣어놨습니다. 데이터 전문가님 나중에 수정 부탁요💨
@Model
final class Anime {
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
final class AnimeQuote {
    @Attribute(.unique) var id: String
    var japanese: [String] // 원문 대사
    var pronunciation: [String] // 발음 정보
    var korean: [String] // 한국어 번역
    var timeMark: [Double] // 각 단어가 시작되는 타임마크
    var voicingTime: Double // 말하기 Speed 채점을 위한 기준
    var audioFile: String // 음성 파일 로컬 경로
    
    init(id: String, japanese: [String], pronunciation: [String], korean: [String], timeMark: [Double], voicingTime: Double, audioFile: String) {
        self.id = id
        self.japanese = japanese
        self.pronunciation = pronunciation
        self.korean = korean
        self.timeMark = timeMark
        self.voicingTime = voicingTime
        self.audioFile = audioFile
    }
}

//extension ModelContext {
//    func fetch<T: PersistentModel>(_ modelType: T.Type) -> [T] {
//        do {
//            return try self.fetch(FetchDescriptor<T>())
//        } catch {
//            print("Error fetching \(T.self): \(error.localizedDescription)")
//            return []
//        }
//    }
//}

// TODO: 임시 더미데이터 삭제
@Observable class Dummie {
    let animes: [Anime] = [
        Anime(
            id: "ONEPIC",
            title: "원피스",
            quotes: [
                AnimeQuote(
                    id: "quote1",
                    japanese: ["海賊王に", "俺は", "なる"],
                    pronunciation: ["카이조쿠오오니", "오레와", "나루"],
                    korean: ["나는", "해적왕이", "될거야!"],
                    timeMark: [0.0, 2.8, 4.1],
                    voicingTime: 4.0,
                    audioFile: "ONEPIC_010.mov"
                )
            ]
        ),
        Anime(
            id: "JUSULH",
            title: "주술회전",
            quotes: [
                AnimeQuote(
                    id: "quote1",
                    japanese: ["領域展開", "無量空処"],
                    pronunciation: ["료이키텐카이", "무료오크쇼"],
                    korean: ["영역전개", "무량공처"],
                    timeMark: [0.1, 5.0],
                    voicingTime: 8.0,
                    audioFile: "JUSULH_010.mov"
                )
            ]
        ),
        Anime(
            id: "JINGYG",
            title: "진격의 거인",
            quotes: [
                AnimeQuote(
                    id: "quote1",
                    japanese: ["心臓を", "捧げよ"],
                    pronunciation: ["신조오오", "사사게요"],
                    korean: ["심장을", "바쳐라"],
                    timeMark: [0.5,1.4],
                    voicingTime: 3.0,
                    audioFile: "JINGYG_010.mov"
                )
            ]
        ),
        Anime(
            id: "SLDUNK",
            title: "슬램덩크",
            quotes: [
                AnimeQuote(
                    id: "quote1",
                    japanese: ["左手は","添える","だけ"],
                    pronunciation: ["히다리테와", "소에루", "다케"],
                    korean: ["왼손은", "거들뿐"],
                    timeMark: [0.2,0.8,1.1],
                    voicingTime: 3.0,
                    audioFile: "SLDUNK_010.mov"
                )
            ]
        )
        
    ]
}


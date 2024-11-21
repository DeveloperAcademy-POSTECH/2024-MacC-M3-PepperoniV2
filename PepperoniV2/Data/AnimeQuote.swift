//
//  AnimeQuote.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/16/24.
//

import SwiftData

// TODO: 임시로 넣어놨습니다. 데이터 전문가님 나중에 수정 부탁요💨
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

// TODO: 임시 더미데이터 삭제
@Observable class Dummie {
    let animes: [Anime] = [
        Anime(
            id: "anime1",
            title: "진격의 거인",
            quotes: [
                AnimeQuote(
                    id: "quote1",
                    japanese: ["自由はあきらめない！"],
                    pronunciation: ["지유와 아키라메나이!"],
                    korean: ["자유를 포기하지 않아!"],
                    timeMark: [0.0, 1.0],
                    voicingTime: 2.0,
                    audioFile: "attack_on_titan_quote1.mp3",
                    youtubeID: "abcd1234",
                    youtubeStartTime: 12.5,
                    youtubeEndTime: 15.5
                ),
                AnimeQuote(
                    id: "quote2",
                    japanese: ["お前が決めるんだ！"],
                    pronunciation: ["오마에가 키메룬다!"],
                    korean: ["네가 결정하는 거야!"],
                    timeMark: [0.0, 1.5],
                    voicingTime: 2.5,
                    audioFile: "attack_on_titan_quote2.mp3",
                    youtubeID: "abcd1234",
                    youtubeStartTime: 20.0,
                    youtubeEndTime: 23.0
                )
            ]
        ),
        Anime(
            id: "anime2",
            title: "귀멸의 칼날",
            quotes: [
                AnimeQuote(
                    id: "quote3",
                    japanese: ["全集中の呼吸！"],
                    pronunciation: ["젠슈우추우노 코큐우!"],
                    korean: ["전집중의 호흡!"],
                    timeMark: [0.0, 1.2],
                    voicingTime: 1.8,
                    audioFile: "demon_slayer_quote1.mp3",
                    youtubeID: "wxyz5678",
                    youtubeStartTime: 5.0,
                    youtubeEndTime: 6.5
                ),
                AnimeQuote(
                    id: "quote4",
                    japanese: ["守るべきものを守る！"],
                    pronunciation: ["마모루베키 모노오 마모루!"],
                    korean: ["지켜야 할 것을 지킨다!"],
                    timeMark: [0.0, 1.8],
                    voicingTime: 2.2,
                    audioFile: "demon_slayer_quote2.mp3",
                    youtubeID: "wxyz5678",
                    youtubeStartTime: 18.0,
                    youtubeEndTime: 21.0
                )
            ]
        ),
        Anime(
            id: "anime3",
            title: "나의 히어로 아카데미아",
            quotes: [
                AnimeQuote(
                    id: "quote5",
                    japanese: ["君はヒーローになれる！"],
                    pronunciation: ["키미와 히이로-니 나레루!"],
                    korean: ["너는 히어로가 될 수 있어!"],
                    timeMark: [0.0, 1.5],
                    voicingTime: 2.0,
                    audioFile: "my_hero_academia_quote1.mp3",
                    youtubeID: "mnop3456",
                    youtubeStartTime: 10.0,
                    youtubeEndTime: 12.0
                ),
                AnimeQuote(
                    id: "quote6",
                    japanese: ["諦めるな！"],
                    pronunciation: ["아키라메루나!"],
                    korean: ["포기하지 마!"],
                    timeMark: [0.0, 1.0],
                    voicingTime: 1.5,
                    audioFile: "my_hero_academia_quote2.mp3",
                    youtubeID: "mnop3456",
                    youtubeStartTime: 25.0,
                    youtubeEndTime: 26.5
                )
            ]
        ),
        Anime(
            id: "anime4",
            title: "원피스",
            quotes: [
                AnimeQuote(
                    id: "quote7",
                    japanese: ["俺は海賊王になる！"],
                    pronunciation: ["오레와 카이조쿠오우니 나루!"],
                    korean: ["나는 해적왕이 될 거야!"],
                    timeMark: [0.0, 1.5],
                    voicingTime: 2.0,
                    audioFile: "one_piece_quote1.mp3",
                    youtubeID: "qrst6789",
                    youtubeStartTime: 8.0,
                    youtubeEndTime: 10.0
                ),
                AnimeQuote(
                    id: "quote8",
                    japanese: ["仲間を助けるのが俺の仕事だ！"],
                    pronunciation: ["나카마오 타스케루노가 오레노 시고토다!"],
                    korean: ["동료를 돕는 것이 내 일이야!"],
                    timeMark: [0.0, 2.0],
                    voicingTime: 2.5,
                    audioFile: "one_piece_quote2.mp3",
                    youtubeID: "qrst6789",
                    youtubeStartTime: 30.0,
                    youtubeEndTime: 33.0
                )
            ]
        ),
        Anime(
                    id: "anime5",
                    title: "나루토",
                    quotes: [
                        AnimeQuote(
                            id: "quote9",
                            japanese: ["忍道を貫く、それが俺の忍者道だ！"],
                            pronunciation: ["닌도오 츠라누쿠, 소레가 오레노 닌자도다!"],
                            korean: ["닌자의 길을 관철하는 것, 그것이 내 닌자도야!"],
                            timeMark: [0.0, 2.5],
                            voicingTime: 3.0,
                            audioFile: "naruto_quote1.mp3",
                            youtubeID: "uvwx1234",
                            youtubeStartTime: 15.0,
                            youtubeEndTime: 18.0
                        )
                    ]
                ),
                Anime(
                    id: "anime6",
                    title: "도쿄 구울",
                    quotes: [
                        AnimeQuote(
                            id: "quote10",
                            japanese: ["世界は間違っている"],
                            pronunciation: ["세카이와 마치가테이루"],
                            korean: ["세상은 잘못되어 있어"],
                            timeMark: [0.0, 1.5],
                            voicingTime: 2.0,
                            audioFile: "tokyo_ghoul_quote1.mp3",
                            youtubeID: "yzab5678",
                            youtubeStartTime: 7.0,
                            youtubeEndTime: 9.0
                        )
                    ]
                ),
                Anime(
                    id: "anime7",
                    title: "코드 기어스",
                    quotes: [
                        AnimeQuote(
                            id: "quote11",
                            japanese: ["世界を破壊し、世界を創造する"],
                            pronunciation: ["세카이오 하카이시, 세카이오 소우조우스루"],
                            korean: ["세계를 파괴하고, 세계를 창조한다"],
                            timeMark: [0.0, 2.0],
                            voicingTime: 2.5,
                            audioFile: "code_geass_quote1.mp3",
                            youtubeID: "cdef9012",
                            youtubeStartTime: 20.0,
                            youtubeEndTime: 22.5
                        )
                    ]
                ),
                Anime(
                    id: "anime8",
                    title: "죠죠의 기묘한 모험",
                    quotes: [
                        AnimeQuote(
                            id: "quote12",
                            japanese: ["やれやれだぜ"],
                            pronunciation: ["야레야레다제"],
                            korean: ["참 나"],
                            timeMark: [0.0, 1.0],
                            voicingTime: 1.5,
                            audioFile: "jojo_quote1.mp3",
                            youtubeID: "ghij3456",
                            youtubeStartTime: 5.0,
                            youtubeEndTime: 6.5
                        )
                    ]
                ),
                Anime(
                    id: "anime9",
                    title: "강철의 연금술사",
                    quotes: [
                        AnimeQuote(
                            id: "quote13",
                            japanese: ["等価交換だ"],
                            pronunciation: ["토우카코우칸다"],
                            korean: ["등가교환이다"],
                            timeMark: [0.0, 1.2],
                            voicingTime: 1.7,
                            audioFile: "fullmetal_alchemist_quote1.mp3",
                            youtubeID: "klmn7890",
                            youtubeStartTime: 12.0,
                            youtubeEndTime: 13.7
                        )
                    ]
                ),
                Anime(
                    id: "anime10",
                    title: "헌터x헌터",
                    quotes: [
                        AnimeQuote(
                            id: "quote14",
                            japanese: ["楽しいから、やるんだ"],
                            pronunciation: ["타노시이카라, 야룬다"],
                            korean: ["즐겁기 때문에 하는 거야"],
                            timeMark: [0.0, 1.8],
                            voicingTime: 2.3,
                            audioFile: "hunter_x_hunter_quote1.mp3",
                            youtubeID: "opqr1234",
                            youtubeStartTime: 18.0,
                            youtubeEndTime: 20.3
                        )
                    ]
                )
            ]
        }


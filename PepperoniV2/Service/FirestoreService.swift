//
//  FirestoreService.swift
//  PepperoniV2
//
//  Created by Woowon Kang on 11/22/24.
//

import SwiftData
import Firebase
import FirebaseFirestore
import FirebaseStorage

class FirebaseManager {
    let db = Firestore.firestore()
    let storage = Storage.storage()

    /// Firestore에서 데이터를 가져와 로컬 저장소와 SwiftData에 저장
    @MainActor
    func fetchAndStoreData(context: ModelContext) async throws {
        // Firestore 컬렉션 경로 설정
        let animeCollectionPath = "Anime"

        // Firestore에서 모든 Anime 문서 가져오기
        let animeSnapshot = try await db.collection(animeCollectionPath).getDocuments()

        var animeList: [Anime] = []

        // Anime 문서 순회
        for animeDocument in animeSnapshot.documents {
            let animeData = animeDocument.data()
            let animeID = animeDocument.documentID // Firestore의 documentID 사용
            
            if let animeTitle = animeData["animeTitle"] as? String {
                print("Fetching quotes for Anime ID: \(animeID)")

                let quotesPath = "\(animeCollectionPath)/\(animeID)/quotes"
                print("Quotes path: \(quotesPath)")

                let quotesSnapshot = try await db.collection(quotesPath).getDocuments()

                var quotes: [AnimeQuote] = []
                for quoteDocument in quotesSnapshot.documents {
                    let quoteData = quoteDocument.data()
                    let quoteID = quoteDocument.documentID // Firestore의 documentID 사용
                    print("quoteID출력: \(quoteID)")

                    if let japanese = quoteData["japanese"] as? [String],
                       let korean = quoteData["korean"] as? [String],
                       let audioFile = quoteData["audioFile"] as? String {
                        let quote = AnimeQuote(
                            id: quoteID, // SwiftData의 고유 ID 생성
                            japanese: japanese,
                            pronunciation: quoteData["pronunciation"] as? [String] ?? [],
                            korean: korean,
                            timeMark: quoteData["timeMark"] as? [Double] ?? [],
                            voicingTime: quoteData["voicingTime"] as? Double ?? 0.0,
                            audioFile: audioFile,
                            youtubeID: quoteData["youtubeID"] as? String ?? "",
                            youtubeStartTime: quoteData["youtubeStartTime"] as? Double ?? 0.0,
                            youtubeEndTime: quoteData["youtubeEndTime"] as? Double ?? 0.0
                        )
                        quotes.append(quote)
                    } else {
                        print("Missing required fields in quote document: \(quoteDocument.documentID)")
                    }
                }

                let anime = Anime(id: animeID,
                                  title: animeTitle,
                                  quotes: quotes)
                animeList.append(anime)

                print("Loaded Anime: \(animeID), Title: \(animeTitle), Quotes Count: \(quotes.count)")
            } else {
                print("Missing animeTitle in document: \(animeDocument.documentID)")
            }
        }

        // 메인 큐에서 SwiftData 업데이트
        DispatchQueue.main.async {
            animeList.forEach { context.insert($0) }
            do {
                try context.save() // 변경 사항 저장
            } catch {
                print("Error saving context: \(error.localizedDescription)")
            }
        }
    }

    /// Firebase Storage에서 오디오 파일 다운로드
    func downloadAudioFile(audioPath: String) async throws -> URL {
        let fullPath = "Animes/\(audioPath)"
        let storageRef = storage.reference().child(fullPath)
        print("Storage 경로: \(fullPath)")

        // 로컬 저장 경로 설정
        let localURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(audioPath)

        // Firebase Storage에서 메타데이터 가져오기
        let storageMetadata = try await storageRef.getMetadata()

        // 파일이 로컬에 있는지 확인
        if FileManager.default.fileExists(atPath: localURL.path) {
            // 로컬 파일의 속성 확인
            let localAttributes = try FileManager.default.attributesOfItem(atPath: localURL.path)
            if let localFileSize = localAttributes[.size] as? UInt64 {
                // 로컬 파일 크기와 Firebase Storage 파일 크기 비교
                if localFileSize == storageMetadata.size {
                    print("File already exists and is identical. Using local file.")
                    return localURL
                } else {
                    print("File exists locally but is different. Downloading updated file.")
                }
            }
        }

        // Firebase Storage에서 파일 다운로드
        print("Downloading file from Firebase Storage: \(fullPath)")
        return try await withCheckedThrowingContinuation { continuation in
            storageRef.write(toFile: localURL) { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let url = url {
                    continuation.resume(returning: url)
                }
            }
        }
    }
}

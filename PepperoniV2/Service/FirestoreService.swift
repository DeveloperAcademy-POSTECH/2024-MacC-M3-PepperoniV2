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

class FirestoreService {
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

        for animeDocument in animeSnapshot.documents {
            let animeData = animeDocument.data()
            let animeID = animeDocument.documentID // Firestore의 documentID 사용

            guard let animeTitle = animeData["animeTitle"] as? String else {
                print("Missing animeTitle in document: \(animeDocument.documentID)")
                continue
            }

            print("Fetching quotes for Anime ID: \(animeID)")

            let quotesPath = "\(animeCollectionPath)/\(animeID)/quotes"
            let quotesSnapshot: QuerySnapshot

            do {
                quotesSnapshot = try await db.collection(quotesPath).getDocuments()
            } catch {
                print("Error fetching quotes for Anime ID \(animeID): \(error.localizedDescription)")
                continue
            }

            var quotes: [AnimeQuote] = []

            for quoteDocument in quotesSnapshot.documents {
                let quoteData = quoteDocument.data()
                let quoteID = quoteDocument.documentID // Firestore의 documentID 사용

                guard let japanese = quoteData["japanese"] as? [String],
                      let korean = quoteData["korean"] as? [String],
                      let audioFile = quoteData["audioFile"] as? String else {
                    print("Missing required fields in quote document: \(quoteDocument.documentID)")
                    continue
                }

                // 음원 다운로드
                let audioURL: URL
                do {
                    audioURL = try await downloadAudioFile(animeID: animeID, quoteID: quoteID, audioFile: audioFile)
                    print("Audio file downloaded to: \(audioURL.path)")
                } catch {
                    print("Failed to download audio file for Quote ID \(quoteID): \(error.localizedDescription)")
                    continue
                }

                let quote = AnimeQuote(
                    id: quoteID,
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
            }

            let anime = Anime(
                id: animeID,
                title: animeTitle,
                quotes: quotes
            )
            animeList.append(anime)

            print("Loaded Anime: \(animeID), Title: \(animeTitle), Quotes Count: \(quotes.count)")
        }

        // 메인 큐에서 SwiftData 업데이트
//        DispatchQueue.main.async {
//            animeList.forEach { context.insert($0) }
//            do {
//                try context.save() // 변경 사항 저장
//            } catch {
//                print("Error saving context: \(error.localizedDescription)")
//            }
//        }
    }

    /// Firebase Storage에서 오디오 파일 다운로드
    func downloadAudioFile(animeID: String, quoteID: String, audioFile: String) async throws -> URL {
        // Firebase Storage 경로 설정
        let fullPath = "Animes/\(animeID)/\(audioFile)"
        let storageRef = storage.reference().child(fullPath)
        print("Storage 경로: \(fullPath)")

        // 로컬 저장 경로 설정
        let localURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(audioFile)

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
                    print("File downloaded to: \(url.path)")
                    continuation.resume(returning: url)
                }
            }
        }
    }
}

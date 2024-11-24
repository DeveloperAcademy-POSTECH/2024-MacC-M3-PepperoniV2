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
    let syncKey = "isDataSynced"

    /// Firestore에서 데이터를 가져와 로컬 저장소와 SwiftData에 저장
    @MainActor
    func fetchAndStoreData(context: ModelContext) async throws {
        // Firestore 컬렉션 경로 설정
        let animeCollectionPath = "Anime"
        let animeSnapshot = try await db.collection(animeCollectionPath).getDocuments()

        var animeList: [Anime] = []

        for animeDocument in animeSnapshot.documents {
            let animeData = animeDocument.data()
            let animeID = animeDocument.documentID

            guard let animeTitle = animeData["animeTitle"] as? String else {
                print("Missing animeTitle in document: \(animeDocument.documentID)")
                continue
            }

            print("Fetching quotes for Anime ID: \(animeID)")

            let quotesPath = "\(animeCollectionPath)/\(animeID)/quotes"
            let quotesSnapshot = try await db.collection(quotesPath).getDocuments()

            var quotes: [AnimeQuote] = []

            for quoteDocument in quotesSnapshot.documents {
                let quoteData = quoteDocument.data()
                let quoteID = quoteDocument.documentID

                guard let japanese = quoteData["japanese"] as? [String],
                      let korean = quoteData["korean"] as? [String],
                      let audioFile = quoteData["audioFile"] as? String else {
                    print("Missing required fields in quote document: \(quoteDocument.documentID)")
                    continue
                }

                let localFilePath = FileManager.default
                    .urls(for: .documentDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent(audioFile).path

                let storagePath = "Animes/\(animeID)/\(audioFile)"
                let shouldUpdate = try await shouldUpdateFile(filePath: localFilePath, storagePath: storagePath)

                if shouldUpdate {
                    try await downloadAudioFile(storagePath: storagePath, localPath: localFilePath)
                }

                let quote = AnimeQuote(
                    id: quoteID,
                    japanese: japanese,
                    pronunciation: quoteData["pronunciation"] as? [String] ?? [],
                    korean: korean,
                    timeMark: quoteData["timeMark"] as? [Double] ?? [],
                    voicingTime: quoteData["voicingTime"] as? Double ?? 0.0,
                    audioFile: localFilePath,
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
        }

        // 로컬 데이터를 최신 상태로 유지
        DispatchQueue.main.async {
            animeList.forEach { anime in
                if let existingAnime = context.fetch(Anime.self).first(where: { $0.id == anime.id }) {
                    anime.quotes.forEach { newQuote in
                        if !existingAnime.quotes.contains(where: { $0.id == newQuote.id }) {
                            existingAnime.quotes.append(newQuote)
                        }
                    }
                } else {
                    context.insert(anime)
                }
            }
            do {
                try context.save()
                print("Data successfully saved to SwiftData.")
            } catch {
                print("Error saving data to SwiftData: \(error.localizedDescription)")
            }
        }
    }

    /// Firebase Storage 파일 업데이트 확인 및 다운로드
    func shouldUpdateFile(filePath: String, storagePath: String) async throws -> Bool {
        let storageRef = storage.reference().child(storagePath)

        // Firebase Storage 메타데이터 가져오기
        let metadata = try await storageRef.getMetadata()
        guard let storageUpdatedTime = metadata.updated else {
            print("Failed to retrieve updated time from storage.")
            return true // Storage 메타데이터가 없으면 업데이트 강제
        }

        let fileManager = FileManager.default

        // 로컬 파일이 있는지 확인
        guard fileManager.fileExists(atPath: filePath) else {
            print("File does not exist locally. Update required.")
            return true
        }

        // 로컬 파일 메타데이터 가져오기
        let attributes = try fileManager.attributesOfItem(atPath: filePath)
        guard let localUpdatedTime = attributes[.modificationDate] as? Date else {
            print("Failed to retrieve local modification date. Update required.")
            return true
        }

        // 로컬 파일과 Firebase 파일 비교
        if localUpdatedTime < storageUpdatedTime {
            print("Update needed: Local file is older than Storage file.")
            print("Local modified time: \(localUpdatedTime)")
            print("Storage updated time: \(storageUpdatedTime)")
            return true
        }

        print("No update needed: Local file is up-to-date.")
        return false
    }

    func downloadAudioFile(storagePath: String, localPath: String) async throws {
        let storageRef = storage.reference().child(storagePath)
        let localURL = URL(fileURLWithPath: localPath)

        print("Downloading file from Firebase Storage: \(storagePath)")

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            storageRef.write(toFile: localURL) { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    print("File downloaded to: \(localURL.path)")
                    continuation.resume()
                }
            }
        }
    }
}

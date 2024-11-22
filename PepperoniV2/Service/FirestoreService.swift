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
        // 동기화 상태 확인
        guard !isDataSynced() else {
            print("Data already synced. Skipping fetch.")
            return
        }

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

                // 음원 다운로드 및 경로 저장
                let localAudioURL: URL
                do {
                    localAudioURL = try await downloadAudioFile(animeID: animeID, audioFileName: audioFile)
                    print("Audio file downloaded to: \(localAudioURL.path)")
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
                        audioFile: localAudioURL.path, // 로컬 경로 저장
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

        // SwiftData에 저장
        DispatchQueue.main.async {
            animeList.forEach { anime in
                if let existingAnime = context.fetch(Anime.self).first(where: { $0.id == anime.id }) {
                    // 기존 Anime에 대한 Quote 중복 확인 및 추가
                    anime.quotes.forEach { newQuote in
                        if !existingAnime.quotes.contains(where: { $0.id == newQuote.id }) {
                            existingAnime.quotes.append(newQuote)
                        }
                    }
                } else {
                    // Anime 자체가 없으면 새로 추가
                    context.insert(anime)
                }
            }
            do {
                try context.save()
                print("Data successfully saved to SwiftData.")
                self.setDataSynced()
            } catch {
                print("Error saving data to SwiftData: \(error.localizedDescription)")
            }
        }
    }

    // 데이터 동기화 상태 확인
    private func isDataSynced() -> Bool {
        return UserDefaults.standard.bool(forKey: syncKey)
    }

    // 데이터 동기화 상태 저장
    private func setDataSynced() {
        UserDefaults.standard.set(true, forKey: syncKey)
    }

    /// Firebase Storage에서 오디오 파일 다운로드
    func downloadAudioFile(animeID: String, audioFileName: String) async throws -> URL {
        // Firebase Storage 경로 설정
        let fullPath = "Animes/\(animeID)/\(audioFileName)"
        let storageRef = storage.reference().child(fullPath)
        print("Downloading file from Firebase Storage: \(fullPath)")

        // 로컬 저장 경로 설정
        let localURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(audioFileName)

        // 파일이 로컬에 있는지 확인
        if FileManager.default.fileExists(atPath: localURL.path) {
            print("File already exists at: \(localURL.path)")
            return localURL
        }

        // Firebase Storage에서 파일 다운로드
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

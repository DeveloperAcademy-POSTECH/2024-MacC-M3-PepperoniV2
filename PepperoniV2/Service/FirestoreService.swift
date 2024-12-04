//
//  FirestoreService.swift
//  PepperoniV2
//
//  Created by Woowon Kang on 11/22/24.
//

import SwiftData
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

//class FirestoreService {
//    let db = Firestore.firestore()
//    let storage = Storage.storage()
//    let syncKey = "isDataSynced"
//    
//    /// Firestore에서 anime의 타이틀만 불러와서 SwiftData 저장
//    @MainActor
//    func fetchAnimeTitles(context: ModelContext) async throws {
//        // Firestore 컬렉션 경로 설정
//        let animeCollectionPath = "Anime"
//        let animeSnapshot = try await db.collection(animeCollectionPath).getDocuments()
//        
//        var newAnimeTitles: [String] = []
//        
//        // Firestore에서 모든 애니 제목 가져오기
//        for animeDocument in animeSnapshot.documents {
//            let animeData = animeDocument.data()
//            let animeID = animeDocument.documentID
//            
//            guard let animeTitle = animeData["animeTitle"] as? String else {
//                print("Missing animeTitle in document: \(animeDocument.documentID)")
//                continue
//            }
//            
//            // SwiftData에 이미 저장된 애니인지 확인
//            if context.fetch(Anime.self).first(where: { $0.id == animeID }) == nil {
//                // 새로운 Anime 객체 생성 및 SwiftData에 추가
//                let newAnime = Anime(id: animeID, title: animeTitle, quotes: [])
//                context.insert(newAnime)
//                newAnimeTitles.append(animeTitle)
//            }
//        }
//        
//        do {
//            try context.save()
//            print("Successfully saved new anime titles to SwiftData.")
//        } catch {
//            print("Error saving data to SwiftData: \(error.localizedDescription)")
//        }
//
//        // TODO: 확인용, 제거 요망
//        DispatchQueue.main.async {
//            if newAnimeTitles.isEmpty {
//                print("No new anime titles to add.")
//            } else {
//                print("New anime titles: \(newAnimeTitles)")
//            }
//        }
//    }
//
//    /// 사용자가 선택한 애니 데이터를 Firestore에서 불러와 SwiftData와 로컬 저장소에 저장
//    @MainActor
//    func fetchAnimeDetailsAndStore(context: ModelContext, animeID: String, progressCallback: @escaping (Double) -> Void) async throws {
//        let animeCollectionPath = "Anime"
//        let animeDocumentPath = "\(animeCollectionPath)/\(animeID)"
//        let quotesPath = "\(animeDocumentPath)/quotes"
//        
//        let quotesSnapshot = try await db.collection(quotesPath).getDocuments()
//        var quotes: [AnimeQuote] = []
//        
//        for (index, quoteDocument) in quotesSnapshot.documents.enumerated() {
//            let quoteData = quoteDocument.data()
//            let quoteID = quoteDocument.documentID
//            
//            guard let japanese = quoteData["japanese"] as? [String],
//                  let korean = quoteData["korean"] as? [String],
//                  let audioFile = quoteData["audioFile"] as? String else {
//                print("Missing required fields in quote document: \(quoteDocument.documentID)")
//                continue
//            }
//            
//            let localFilePath = FileManager.default
//                .urls(for: .documentDirectory, in: .userDomainMask)[0]
//                .appendingPathComponent(audioFile).path
//            
//            let storagePath = "Animes/\(animeID)/\(audioFile)"
//            let shouldUpdate = try await shouldUpdateFile(filePath: localFilePath, storagePath: storagePath)
//            
//            if shouldUpdate {
//                try await downloadAudioFile(storagePath: storagePath, localPath: localFilePath)
//            }
//            
//            let quote = AnimeQuote(
//                id: quoteID,
//                japanese: japanese,
//                pronunciation: quoteData["pronunciation"] as? [String] ?? [],
//                korean: korean,
//                timeMark: quoteData["timeMark"] as? [Double] ?? [],
//                voicingTime: quoteData["voicingTime"] as? Double ?? 0.0,
//                audioFile: localFilePath,
//                youtubeID: quoteData["youtubeID"] as? String ?? "",
//                youtubeStartTime: quoteData["youtubeStartTime"] as? Double ?? 0.0,
//                youtubeEndTime: quoteData["youtubeEndTime"] as? Double ?? 0.0
//            )
//            quotes.append(quote)
//            
//            let progress = Double(index + 1) / Double(quotesSnapshot.documents.count)
//            progressCallback(progress)
//        }
//        
//        // swiftdata의 anime와 firebase에서 불러온 anime를 비교, 없으면 swiftdata에 넣어줌
//        if let existingAnime = context.fetch(Anime.self).first(where: { $0.id == animeID }) {
//            quotes.forEach { newQuote in
//                if !existingAnime.quotes.contains(where: { $0.id == newQuote.id }) {
//                    existingAnime.quotes.append(newQuote)
//                }
//            }
//        }
//        
//        do {
//            try context.save()
//            print("Successfully updated anime details and quotes to SwiftData.")
//        } catch {
//            print("Error saving details to SwiftData: \(error.localizedDescription)")
//        }
//    }
//    
//    /// Firebase Storage 파일 업데이트 확인 및 다운로드
//    func shouldUpdateFile(filePath: String, storagePath: String) async throws -> Bool {
//        let storageRef = storage.reference().child(storagePath)
//
//        // Firebase Storage 메타데이터 가져오기
//        let metadata = try await storageRef.getMetadata()
//        guard let storageUpdatedTime = metadata.updated else {
//            print("Failed to retrieve updated time from storage.")
//            return true // Storage 메타데이터가 없으면 업데이트 강제
//        }
//
//        let fileManager = FileManager.default
//
//        // 로컬 파일이 있는지 확인
//        guard fileManager.fileExists(atPath: filePath) else {
//            print("File does not exist locally. Update required.")
//            return true
//        }
//
//        // 로컬 파일 메타데이터 가져오기
//        let attributes = try fileManager.attributesOfItem(atPath: filePath)
//        guard let localUpdatedTime = attributes[.modificationDate] as? Date else {
//            print("Failed to retrieve local modification date. Update required.")
//            return true
//        }
//
//        // 로컬 파일과 Firebase 파일 비교
//        if localUpdatedTime < storageUpdatedTime {
//            print("Update needed: Local file is older than Storage file.")
//            print("Local modified time: \(localUpdatedTime)")
//            print("Storage updated time: \(storageUpdatedTime)")
//            return true
//        }
//
//        print("No update needed: Local file is up-to-date.")
//        return false
//    }
//
//    func downloadAudioFile(storagePath: String, localPath: String) async throws {
//        let storageRef = storage.reference().child(storagePath)
//        let localURL = URL(fileURLWithPath: localPath)
//
//        print("Downloading file from Firebase Storage: \(storagePath)")
//
//        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
//            storageRef.write(toFile: localURL) { url, error in
//                if let error = error {
//                    continuation.resume(throwing: error)
//                } else {
//                    print("File downloaded to: \(localURL.path)")
//                    continuation.resume()
//                }
//            }
//        }
//    }
//}

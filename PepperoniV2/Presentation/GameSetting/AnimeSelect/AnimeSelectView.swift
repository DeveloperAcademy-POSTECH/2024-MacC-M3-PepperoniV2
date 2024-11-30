//
//  UserSelectView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/16/24.
//

import SwiftUI
import SwiftData

struct AnimeSelectView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Binding var isPresented: Bool
    @Environment(FetchDataState.self) var fetchDataState
    @Bindable var viewModel: AnimeSelectViewModel
    @Environment(GameViewModel.self) var gameViewModel
    @State private var searchText: String = ""
    @State private var isLoading = false
    private let firestoreService = FirestoreService()
    
    // SwiftData에서 Anime 데이터를 가져오기
    @Query var animes: [Anime]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                Header(
                    title: "애니 선택",
                    dismissAction: {
                        isPresented = false
                    },
                    dismissButtonType: .icon
                )
                
                // MARK: -검색창
                HStack (spacing: 14){
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .regular))
                    
                    TextField(
                        "애니 검색",
                        text: $searchText,
                        prompt: Text("애니 검색")
                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                    )
                    .hakgyoansim(size: 16)
                }
                .padding(.horizontal, 13)
                .padding(.vertical, 9)
                .foregroundColor(.white)
                .cornerRadius(6)
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color(red: 0.47, green: 0.47, blue: 0.47), lineWidth: 1)
                }
                .frame(height: 40)
                .padding(.horizontal)
                .padding(.top, 8)
                
                DashLine()
                    .stroke(style: .init(dash: [6]))
                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                    .frame(height: 1)
                    .padding(.vertical, 25)
                    .padding(.horizontal, 16)
                
                // MARK: -ProgressView
                if fetchDataState.isFetchingData || isLoading {
                    HStack {
                        Spacer()
                        ProgressView("명대사를 불러오는 중...")
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.black.opacity(0.8)) // 반투명 배경
                            )
                            .foregroundStyle(.white)
                        Spacer()
                    }
                }
                
                // MARK: -anime 리스트
                List(Array(currentAnimes.enumerated()), id: \.element.id) { index, anime in
                    AnimeRowView(
                        anime: anime,
                        isSelected: viewModel.tempSelectedAnime?.id == anime.id
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .onTapGesture {
                        Task {
                            await selectAnime(anime) // 선택된 애니 데이터 로드
                        }
                    }
                    .padding(.bottom, index == currentAnimes.count - 1 ? 60 : 0)
                }
                .listStyle(.plain)
                .padding(.bottom,60)
                
            }
            .background(.black)
            
            VStack {
                // MARK: -저장 버튼
                Button {
                    if let selectedAnime = viewModel.tempSelectedAnime {
                        gameViewModel.selectedAnime = selectedAnime // GameViewModel에 Anime 설정
                        viewModel.saveChanges()
                        isPresented = false
                    }
                } label: {
                    Text("저장")
                        .suit(.extraBold, size: 16)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
                .background(Color(red: 0.86, green: 0.85, blue: 0.92))
                .cornerRadius(60)
                .padding(.horizontal)
            }
            .frame(height: 140, alignment: .bottom)
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: .black.opacity(0), location: 0.00),
                        Gradient.Stop(color: .black, location: 0.8),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
            )
        }
    }
    
    /// 현재 보여지는 애니 리스트
    private var currentAnimes: [Anime] {
        if searchText.isEmpty {
            return animes
        } else {
            // 검색어 공백 제거
            let normalizedSearchText = searchText.replacingOccurrences(of: " ", with: "")
            return animes.filter {
                // 애니 제목 공백 제거
                let normalizedTitle = $0.title.replacingOccurrences(of: " ", with: "")
                return normalizedTitle.localizedCaseInsensitiveContains(normalizedSearchText)
            }
        }
    }
    
    // 애니 선택 및 데이터 로드
    @MainActor
    private func selectAnime(_ anime: Anime) async {
        // quotes가 이미 저장되어 있으면 바로 선택
        if !anime.quotes.isEmpty {
            viewModel.selectAnime(anime)
            return
        }
        
        isLoading = true
        do {
            try await firestoreService.fetchAnimeDetailsAndStore(context: modelContext, animeID: anime.id) // modelContext 전달
            viewModel.selectAnime(anime)
        } catch {
            print("Failed to load anime details: \(error.localizedDescription)")
        }
        isLoading = false
    }
}

struct DashLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

struct AnimeRowView: View {
    let anime: Anime
    let isSelected: Bool
    
    private var needDownload: Bool {
        anime.quotes.isEmpty
    }
    
    var body: some View {
        HStack {
            VStack {
                if needDownload {
                    Image("NeedDownload")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(Color.ppDarkGray_01)
                        .padding(.leading, 11)
                } else if isSelected {
                    Image("Checkmark")
                        .resizable()
                        .frame(width:35, height: 32, alignment: .center)
                        .foregroundStyle(.white)
                        .padding(.leading, 7)
                }
            }
            .frame(width: 48)
            
            HStack {
                Text(anime.title)
                    .foregroundStyle(needDownload ? Color.ppDarkGray_01: .white)
                    .suit(.medium, size: 16)
                
                Spacer()
            }
            .padding(.horizontal)
            .frame(maxHeight: .infinity)
            .background(needDownload ? LinearGradient(stops: [
                           Gradient.Stop(color: Color.ppDarkGray_04, location: 0.0),
                           Gradient.Stop(color: Color.ppDarkGray_04, location: 1.00),
                       ],
                                                                 startPoint: UnitPoint(x: 0, y: 0.5),
                                                                 endPoint: UnitPoint(x: 1, y: 0.5)) : (isSelected ? LinearGradient.gradient3 : LinearGradient(
                                                                   stops: [
                                                                       Gradient.Stop(color: Color(hex: "313037"), location: 0.12),
                                                                       Gradient.Stop(color: Color(hex: "0D0D0D"), location: 1.00),
                                                                   ],
                                                                   startPoint: UnitPoint(x: 0, y: 0.5),
                                                                   endPoint: UnitPoint(x: 1, y: 0.5)
                                                                 )))
        }
        .frame(height: 78)
        .cornerRadius(10)
        .overlay {
            if needDownload {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.ppDarkGray_01, lineWidth: 2)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(LinearGradient.gradient3, lineWidth: 2)
            }
            
        }
        .padding(.horizontal)
        .padding(.top, 2)
        .padding(.bottom, 12)
    }
}
//
//struct AnimeSelectView_Previews: PreviewProvider {
//    static var previews: some View {
//        let gameData = GameData()
//        let viewModel = AnimeSelectViewModel(gameData: gameData)
//
//        return AnimeSelectView(isPresented: .constant(true), viewModel: viewModel)
//    }
//}

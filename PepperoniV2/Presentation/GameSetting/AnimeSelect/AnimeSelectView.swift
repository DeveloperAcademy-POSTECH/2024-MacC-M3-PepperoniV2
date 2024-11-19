//
//  UserSelectView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/16/24.
//

import SwiftUI

struct AnimeSelectView: View {
    @Binding var isPresented: Bool
    @Bindable var viewModel: AnimeSelectViewModel
    @State private var searchText: String = ""
    
    // TODO: 더미데이터 삭제
    @State var dummie = Dummie()
    
    var body: some View {
        VStack{
            TextField("검색어를 입력하세요", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            List(currentAnimes) { anime in
                HStack {
                    Text(anime.title)
                    
                    Spacer()
                    
                    if viewModel.tempSelectedAnime?.id == anime.id {
                        Image(systemName: "checkmark")
                    }
                }
                .onTapGesture {
                    viewModel.selectAnime(anime)
                }
            }
        }
        
        Button {
            viewModel.saveChanges()
            isPresented = false
        } label: {
            Text("저장")
        }
        
        Button {
            isPresented = false
        } label: {
            Text("닫기")
        }
    }
    
    /// 현재 보여지는 애니 리스트
    private var currentAnimes: [Anime] {
        if searchText.isEmpty {
            return dummie.animes
        } else {
            // 검색어 공백 제거
            let normalizedSearchText = searchText.replacingOccurrences(of: " ", with: "")
            return dummie.animes.filter {
                // 애니 제목 공백 제거
                let normalizedTitle = $0.title.replacingOccurrences(of: " ", with: "")
                return normalizedTitle.localizedCaseInsensitiveContains(normalizedSearchText)
            }
        }
    }
}

struct AnimeSelectView_Previews: PreviewProvider {
    static var previews: some View {
        let gameData = GameData()
        let viewModel = AnimeSelectViewModel(gameData: gameData)
        
        return AnimeSelectView(isPresented: .constant(true), viewModel: viewModel)
    }
}


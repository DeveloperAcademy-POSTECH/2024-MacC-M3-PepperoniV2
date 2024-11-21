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
                .font(.system(size: 16, weight: .medium))
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 9)
            .foregroundColor(.white)
            .cornerRadius(6)
            .overlay {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(red: 0.47, green: 0.47, blue: 0.47), lineWidth: 1)
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
              
            // MARK: -anime 리스트
            List(currentAnimes) { anime in
                AnimeRowView(
                    anime: anime,
                    isSelected: viewModel.tempSelectedAnime?.id == anime.id
                )
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .onTapGesture {
                    viewModel.selectAnime(anime)
                }
            }
            .listStyle(.plain)
            
            // MARK: -저장 버튼
            Button {
                viewModel.saveChanges()
                isPresented = false
            } label: {
                Text("저장")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
            .background(Color(red: 0.86, green: 0.85, blue: 0.92))
            .cornerRadius(60)
            .padding(.horizontal)
        }
        .background(.black)
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
    
    var body: some View {
        HStack {
            VStack {
                if isSelected {
                    Image("Checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36)
                        .padding(.leading, 6)
                }
            }
            .frame(width: 48)
            
            HStack {
                Text(anime.title)
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .medium))
                
                Spacer()
            }
            .padding(.horizontal)
            .frame(maxHeight: .infinity)
            .background(isSelected ? Color(red: 0.25, green: 0.91, blue: 1) : Color(red: 0.19, green: 0.19, blue: 0.22))
        }
        .frame(height: 78)
        .cornerRadius(10)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(red: 0.47, green: 0.47, blue: 0.47), lineWidth: 2)
        }
        .padding(.horizontal)
        .padding(.bottom, 14)
    }
}

struct AnimeSelectView_Previews: PreviewProvider {
    static var previews: some View {
        let gameData = GameData()
        let viewModel = AnimeSelectViewModel(gameData: gameData)
        
        return AnimeSelectView(isPresented: .constant(true), viewModel: viewModel)
    }
}


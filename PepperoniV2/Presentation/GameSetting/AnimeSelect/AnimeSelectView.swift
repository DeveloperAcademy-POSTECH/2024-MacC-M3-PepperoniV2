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
                .padding(.bottom,60)
            }
            .background(.black)
            
            VStack {
                // MARK: -저장 버튼
                Button {
                    viewModel.saveChanges()
                    isPresented = false
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
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20, alignment: .center)
                        .foregroundStyle(.white)
                        .padding(.leading, 7)
                }
            }
            .frame(width: 48)
            
            HStack {
                Text(anime.title)
                    .foregroundStyle(.white)
                    .suit(.medium, size: 16)
                
                Spacer()
            }
            .padding(.horizontal)
            .frame(maxHeight: .infinity)
            .background(isSelected ? LinearGradient.gradient3 : LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(hex: "313037"), location: 0.12),
                    Gradient.Stop(color: Color(hex: "0D0D0D"), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0, y: 0.5),
                endPoint: UnitPoint(x: 1, y: 0.5)
            ))
        }
        .frame(height: 78)
        .cornerRadius(10)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(LinearGradient.gradient3, lineWidth: 2)
        }
        .padding(.horizontal)
        .padding(.top, 2)
        .padding(.bottom, 12)
    }
}

struct AnimeSelectView_Previews: PreviewProvider {
    static var previews: some View {
        let gameData = GameData()
        let viewModel = AnimeSelectViewModel(gameData: gameData)
        
        return AnimeSelectView(isPresented: .constant(true), viewModel: viewModel)
    }
}


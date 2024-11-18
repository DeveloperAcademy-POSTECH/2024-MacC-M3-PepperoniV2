//
//  UserSelectView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/16/24.
//

import SwiftUI

struct AnimeSelectView: View {
    @Binding var isPresented: Bool
    @Bindable var gameData: GameData
    // TODO: 더미데이터 삭제
    @State var dummie = Dummie()
    
    var body: some View {
        List(dummie.animes) { anime in
            HStack {
                Text(anime.title)
                Spacer()
                if gameData.selectedAnime?.id == anime.id {
                    Image(systemName: "checkmark")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                gameData.selectedAnime = anime
            }
        }
        
        Button {
            isPresented = false // 화면 닫기
        } label: {
            Text("닫기")
        }
    }
}

struct AnimeSelectView_Previews: PreviewProvider {
    static var previews: some View {
        let gameData = GameData()
        
        return AnimeSelectView(isPresented: .constant(true), gameData: GameData())
    }
}


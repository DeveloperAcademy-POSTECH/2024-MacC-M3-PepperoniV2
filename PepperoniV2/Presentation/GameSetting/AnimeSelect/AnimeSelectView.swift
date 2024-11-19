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
    // TODO: 더미데이터 삭제
    @State var dummie = Dummie()
    
    var body: some View {
        List(dummie.animes) { anime in
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
}

struct AnimeSelectView_Previews: PreviewProvider {
    static var previews: some View {
        let gameData = GameData()
        let viewModel = AnimeSelectViewModel(gameData: gameData)
        
        return AnimeSelectView(isPresented: .constant(true), viewModel: viewModel)
    }
}


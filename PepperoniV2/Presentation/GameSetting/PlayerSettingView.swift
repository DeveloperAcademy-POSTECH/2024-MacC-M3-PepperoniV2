//
//  PlayerSettingView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/16/24.
//

import SwiftUI

struct PlayerSettingView: View {
    @Binding var isPresented: Bool
    @Bindable var viewModel: PlayerSettingViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("인원 설정")
                .font(.title)
            
            // 인원 수 조정
            HStack {
                Button(action: {
                    viewModel.removePlayer()
                }) {
                    Image(systemName: "minus.circle")
                        .font(.title)
                }
                .disabled(viewModel.gameData.players.count <= 1)
                
                Text("\(viewModel.gameData.players.count)")
                    .font(.title)
                    .padding(.horizontal)
                
                Button(action: {
                    viewModel.addPlayer()
                }) {
                    Image(systemName: "plus.circle")
                        .font(.title)
                }
                .disabled(viewModel.gameData.players.count >= 10)
            }
        }
        
        Button {
            isPresented = false
        } label: {
            Text("닫기")
        }
    }
}

struct PlayerSettingView_Previews: PreviewProvider {
    static var previews: some View {
        let gameData = GameData()
        let viewModel = PlayerSettingViewModel(gameData: gameData)
        
        return PlayerSettingView(isPresented: .constant(true), viewModel: viewModel)
    }
}


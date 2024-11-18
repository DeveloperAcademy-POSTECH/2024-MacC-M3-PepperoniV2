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
            
            // MARK: - 리셋 버튼
            Button {
                viewModel.resetPlayer()
            } label: {
                Text("reset")
            }

            // MARK: - 인원 수 조정
            HStack {
                Button {
                    viewModel.removePlayer()
                } label: {
                    Image(systemName: "minus.circle")
                        .font(.title)
                }
                .disabled(viewModel.tempGameData.players.count <= 1)
                
                Text("\(viewModel.tempGameData.players.count)")
                    .font(.title)
                    .padding(.horizontal)
                
                Button {
                    viewModel.addPlayer()
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title)
                }
                .disabled(viewModel.tempGameData.players.count >= 10)
            }
            
            // MARK: - 플레이어 닉네임 설정
            List {
                ForEach(Array(viewModel.tempGameData.players.enumerated()), id: \.1.turn) { index, player in
                    HStack {
                        Text("\(player.turn)")
                            .font(.headline)
                        
                        TextField("\(player.nickname ?? "\(index + 1)번")", text: Binding(
                            get: {
                                player.nickname ?? "\(index + 1)번"
                            },
                            set: { newValue in
                                viewModel.updateNickname(for: index, nickname: newValue)
                            }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            .listStyle(.plain)
        }

        Button {
            viewModel.saveChanges()
            isPresented = false
        } label: {
            Text("저장")
        }
        
        // TODO: 닫기 버튼 네비게이션 툴바에 넣기
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


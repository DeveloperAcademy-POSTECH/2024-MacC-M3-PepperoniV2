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
        VStack(spacing: 0) {
            Header(
                title: "인원 설정",
                dismissAction: {
                    isPresented = false
                }
                dismissButtonType: .icon
            )
            
            // MARK: - 리셋 버튼
            Button {
                viewModel.resetPlayer()
            } label: {
                Image("PlayerResetButton")
            }
            .padding(.top, 18)

            // MARK: - 인원 수 조정
            // TODO: - 배경에 gradient
            HStack {
                Button {
                    viewModel.removePlayer()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 45, weight: .bold))
                        .foregroundStyle(Color(red: 0.25, green: 0.91, blue: 1))
                }
                .disabled(viewModel.tempPlayers.count <= 1)
                
                Spacer()
                
                Text("\(viewModel.tempPlayers.count)")
                    .font(.system(size: 45, weight: .bold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button {
                    viewModel.addPlayer()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 45, weight: .bold))
                        .foregroundStyle(Color(red: 0.25, green: 0.91, blue: 1))
                }
                .disabled(viewModel.tempPlayers.count >= 10)
            }
            .padding(.top, 39)
            .padding(.bottom, 58)
            .padding(.horizontal, 71)
            
            // MARK: - 플레이어 닉네임 리스트
            List {
                ForEach(Array(viewModel.tempPlayers.enumerated()), id: \.1.turn) { index, player in
                    PlayerRowView(
                        player: player,
                        index: index,
                        updateNickname: { idx, newValue in
                            viewModel.updateNickname(for: idx, nickname: newValue)
                        }
                    )
                }
            }
            .scrollIndicators(.hidden)
            .listStyle(.plain)
            .padding(.top, 28)
            .padding(.horizontal, 60)
            
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
}

struct PlayerRowView: View {
    let player: Player
    let index: Int
    let updateNickname: (Int, String) -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack {
                Text("\(player.turn)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.93, green: 0.93, blue: 0.96))
            }
            .frame(width: 70, height: 60)
            .background(Color(red: 0.08, green: 0.08, blue: 0.08))
            .cornerRadius(18)

            VStack {
                TextField(
                    "\(player.nickname ?? "\(index + 1)번")",
                    text: Binding(
                        get: {
                            player.nickname ?? "\(index + 1)번"
                        },
                        set: { newValue in
                            updateNickname(index, newValue)
                        }
                    )
                )
                .foregroundStyle(.white)
                .font(.system(size: 20, weight: .medium))
                .background(Color(red: 0.19, green: 0.19, blue: 0.22))
                .cornerRadius(10)
                .multilineTextAlignment(.center)
            }
            .frame(height: 60)
            .foregroundStyle(.white)
            .font(.system(size: 20, weight: .medium))
            .background(Color(red: 0.19, green: 0.19, blue: 0.22))
            .cornerRadius(10)
            .multilineTextAlignment(.center)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .padding(.bottom, 16)
    }
}

struct PlayerSettingView_Previews: PreviewProvider {
    static var previews: some View {
        let gameData = GameData()
        let viewModel = PlayerSettingViewModel(gameData: gameData)
        
        return PlayerSettingView(isPresented: .constant(true), viewModel: viewModel)
    }
}

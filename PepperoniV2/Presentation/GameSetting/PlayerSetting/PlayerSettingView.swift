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
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    Header(
                        title: "인원 설정",
                        dismissAction: {
                            isPresented = false
                        },
                        dismissButtonType: .icon
                    )
                    
                    // MARK: - 리셋 버튼
                    Button {
                        viewModel.resetPlayer()
                    } label: {
                        Image("PlayerResetButton")
                    }
                    .padding(.top, 15)
                    
                    // MARK: - 인원 수 조정
                    // TODO: - 배경에 gradient
                    HStack {
                        Button {
                            viewModel.removePlayer()
                            HapticManager.instance.impact(style: .light)
                        } label: {
                            Image(viewModel.tempPlayers.count <= 2 ? "PlayerMinusButton_disabled" : "PlayerMinusButton")
                        }
                        .disabled(viewModel.tempPlayers.count <= 2)
                                            
                        Spacer()
                        
                        Text("\(viewModel.tempPlayers.count)")
                            .hakgyoansim(size: 45)
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Button {
                            viewModel.addPlayer()
                            HapticManager.instance.impact(style: .light)
                        } label: {
                            Image(viewModel.tempPlayers.count >= 10 ? "PlayerPlusButton_disabled" : "PlayerPlusButton")
                        }
                        .disabled(viewModel.tempPlayers.count >= 10)
                    }
                    .padding(.top, 39)
                    .padding(.bottom, 58)
                    .padding(.horizontal, 71)
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: .clear, location: 0.00),
                                Gradient.Stop(color: Color(hex: "313037").opacity(0.81), location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                        )
                    )
                    
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
                    .padding(.top, 32)
                    .padding(.horizontal, 60)
                    .padding(.bottom,60)
                }
                
                // MARK: -저장 버튼
                VStack {
                    Button {
                        viewModel.saveChanges()
                        isPresented = false
                    } label: {
                        Text("저장")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.ppBlack_01)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                    .background(Color.ppBlueGray)
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
                .position(x: geometry.size.width / 2, y: geometry.size.height - 70)
            }
        }
        .background(.black)
        .ignoresSafeArea(.keyboard)
    }
}

struct PlayerRowView: View {
    let player: Player
    let index: Int
    let updateNickname: (Int, String) -> Void
    
    @State private var isEditing: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            VStack {
                Text("\(player.turn)")
                    .hakgyoansim(size: 20)
                    .foregroundColor(Color(red: 0.93, green: 0.93, blue: 0.96))
            }
            .frame(width: 70, height: 60)
            .background(Color(red: 0.08, green: 0.08, blue: 0.08))
            .cornerRadius(18)
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(RadialGradient(
                        gradient: Gradient(stops: [
                            Gradient.Stop(color: Color(hex: "A52DEF"), location: 0.01),
                            Gradient.Stop(color: Color(hex: "9C34F0"), location: 0.06),
                            Gradient.Stop(color: Color(hex: "6B56F4"), location: 0.36),
                            Gradient.Stop(color: Color(hex: "4ADBFF"), location: 1.00),
                        ]),
                        center: UnitPoint(x: 0.62, y: -0.39),
                        startRadius: 20,
                        endRadius: 80
                    ), lineWidth: 1)
            }
            
            VStack {
                TextField(
                    "\(index + 1)번",
                    text: Binding(
                        get: {
                            player.nickname ?? ""
                        },
                        set: { newValue in
                            updateNickname(index, newValue)
                        }
                    ),
                    prompt: Text(isFocused ? "" : "\(index + 1)번")
                        .foregroundStyle(Color.ppWhiteGray)
                )
                .foregroundStyle(.white)
                .suit(.medium, size: 20)
                .background(Color(red: 0.19, green: 0.19, blue: 0.22))
                .cornerRadius(10)
                .multilineTextAlignment(.center)
                .focused($isFocused)
            }
            .frame(height: 60)
            .foregroundStyle(Color.ppWhiteGray)
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

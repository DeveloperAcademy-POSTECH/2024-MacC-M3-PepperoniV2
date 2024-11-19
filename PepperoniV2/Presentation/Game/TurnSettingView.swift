//
//  TurnSettingView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI

struct TurnSettingView: View {
    @EnvironmentObject var router: Router
    @Environment(GameViewModel.self) var gameViewModel
    
    @StateObject var manager: RouletteManager = RouletteManager(players: [])
    
    var body: some View {
        VStack {
            RouletteTriangle()
                .fill(Color.black)
                .frame(width: 20, height: 40)
                .padding(20)
            
            ZStack {
                Circle()
                    .fill(.clear)
                    .frame(width: 300, height: 300)
                    .overlay(
                        ZStack {
                            ForEach(manager.players.indices, id:\.self) { index in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(style: StrokeStyle(lineWidth: 2))
                                        .frame(width: 100, height: 50)
                                    Text(manager.players[index].nickname ?? "")
                                }
                                .offset(y: -150)
                                .rotationEffect(.degrees(Double(index) * manager.sectorAngle))
                            }
                        }
                    )
                    .rotationEffect(.degrees(manager.rotation))
                    .animation(.easeOut(duration: manager.isSpinning ? 3 : 0), value: manager.rotation)
            }
            .onTapGesture {
                manager.spinRoulette()
            }
        }
        Button {
            router.push(screen: Game.videoPlay)
            if let firstPlayer = manager.selectedItem{
                gameViewModel.changeTurn(first: firstPlayer)
            }
        } label: {
            Text("다음")
        }
        .onAppear {
            manager.players = gameViewModel.players
        }
    }
}

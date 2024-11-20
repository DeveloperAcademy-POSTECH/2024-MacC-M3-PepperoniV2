//
//  ScoreView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI

struct ScoreView: View {
    @EnvironmentObject var router: Router
    @Environment(GameViewModel.self) var gameViewModel
    
    var body: some View {
        HStack{
            VStack{
                Text("\(gameViewModel.temporaryPronunciationScore)")
                Text("발음")
            }
            VStack{
                Text("\(gameViewModel.temporaryIntonationScore)")
                Text("억양")
            }
            VStack{
                Text("\(gameViewModel.temporaryIntonationScore)")
                Text("스피드")
            }
        }
        Button {
            if gameViewModel.turnComplete < gameViewModel.players.count-1{
                DispatchQueue.main.async{
                    gameViewModel.players[gameViewModel.turnComplete].score = Int(gameViewModel.temporaryPronunciationScore + gameViewModel.temporaryIntonationScore + gameViewModel.temporarySpeedScore)
                    gameViewModel.turnComplete += 1
                    router.pop(depth: 1)
                }
            } else if gameViewModel.turnComplete == gameViewModel.players.count-1 {
                DispatchQueue.main.async{
                    gameViewModel.players[gameViewModel.turnComplete].score = Int(gameViewModel.temporaryPronunciationScore + gameViewModel.temporaryIntonationScore + gameViewModel.temporarySpeedScore)
                    router.push(screen: Game.ranking)
                }
            }
            
        } label: {
            Text("다음")
        }
    }
}

#Preview {
    ScoreView()
}

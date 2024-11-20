//
//  RankingView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI

struct RankingView: View {
    @EnvironmentObject var router: Router
    @Environment(GameViewModel.self) var gameViewModel

    @State var rankedPlayers: [Player] = []
    
    var body: some View {
        VStack{
            
            ForEach(rankedPlayers, id:\.nickname) { player in
                HStack{
                    Text("\(player.nickname)")
                    Text("\(player.score)")
                }
            }
            Button {
                // 현재는 turnSetting으로 이동
                // 3: VideoPlay로 이동
                gameViewModel.retryThisQuote()
                router.pop(depth: 4)
            } label: {
                Text("다시하기")
            }
            
            Button {
                router.popToRoot()
            } label: {
                Text("나가기")
            }
        }
        .onAppear{
            rankedPlayers = gameViewModel.players.sorted { player1, player2 in
                player1.score > player2.score
            }
        }
    }
}

#Preview {
    RankingView()
}

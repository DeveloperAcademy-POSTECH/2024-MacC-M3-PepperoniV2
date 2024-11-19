//
//  TurnSettingView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI

struct TurnSettingView: View {
    @EnvironmentObject var router: Router
    @Environment(GameData.self) var gameData
    
    var body: some View {
        Text("TurnSetting")
        
        Text("\(gameData.selectedQuote?.korean[0])")
        
        Button {
            router.push(screen: Game.videoPlay)
        } label: {
            Text("다음")
        }
    }
}

#Preview {
    TurnSettingView()
}

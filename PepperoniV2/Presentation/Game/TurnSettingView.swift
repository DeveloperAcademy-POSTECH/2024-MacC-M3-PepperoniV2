//
//  TurnSettingView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI

struct TurnSettingView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        Text("TurnSetting")
        
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

//
//  RankingView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI

struct RankingView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        Text("Ranking")
        
        Button {
            // 현재는 turnSetting으로 이동
            // 3: VideoPlay로 이동
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
}

#Preview {
    RankingView()
}

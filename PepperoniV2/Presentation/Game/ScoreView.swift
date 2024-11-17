//
//  ScoreView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI

struct ScoreView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        Text("Score")
        
        Button {
            router.push(screen: Game.ranking)
        } label: {
            Text("다음")
        }
    }
}

#Preview {
    ScoreView()
}

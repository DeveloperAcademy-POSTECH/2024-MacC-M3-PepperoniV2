//
//  SpeakingView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI

struct SpeakingView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        Text("Speaking")
        
        Button {
            router.push(screen: Game.score)
        } label: {
            Text("다음")
        }
    }
}

#Preview {
    SpeakingView()
}

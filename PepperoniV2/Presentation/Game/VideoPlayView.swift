//
//  VideoPlayView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI

struct VideoPlayView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        Text("VideoPlay")
        
        Button {
            router.push(screen: Game.speaking)
        } label: {
            Text("다음")
        }
    }
}

#Preview {
    VideoPlayView()
}

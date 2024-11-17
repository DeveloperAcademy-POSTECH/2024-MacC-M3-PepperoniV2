//
//  UserSelectView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/16/24.
//

import SwiftUI

struct AnimeSelectView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        Text("AnimeSelect")
        
        Button {
            isPresented = false // 화면 닫기
        } label: {
            Text("닫기")
        }
    }
}

#Preview {
    AnimeSelectView(isPresented: .constant(true))
}

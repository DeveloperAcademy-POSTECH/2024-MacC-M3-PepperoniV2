//
//  PlayerSettingView.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/16/24.
//

import SwiftUI

struct PlayerSettingView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        Text("PlayerSetting")
        
        Button {
            isPresented = false
        } label: {
            Text("닫기")
        }
    }
}

#Preview {
    PlayerSettingView(isPresented: .constant(true))
}

//
//  Header.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/19/24.
//

import SwiftUI

struct Header: View {
    var title: String
    var dismissAction: (() -> Void)?
    var dismissButtonType: DismissButtonType?
    
    enum DismissButtonType {
        case text(String)
        case icon(String)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                // 타이틀
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .frame(width: geometry.size.width, alignment: .center)
                    .foregroundStyle(.white)
                
                // 버튼
                if let dismissAction = dismissAction, let buttonType = dismissButtonType {
                    HStack {
                        Spacer()
                        
                        Button(action: dismissAction) {
                            switch buttonType {
                            case .text(let text):
                                Text(text)
                                    .font(.system(size: 14, weight: .bold))
                            case .icon(let iconName):
                                Image(systemName: iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18)
                                    .fontWeight(.medium)
                                
                            }
                        }
                        .foregroundStyle(.white)
                        .padding(.trailing, 16)
                    }
                    .frame(width: geometry.size.width, alignment: .trailing)
                }
            }
            .padding(.top, 6)
        }
        .frame(height: 50)
        .background(Color.black)
    }
}

#Preview {
    Header(
        title: "애니 선택",
        dismissAction: {
            print("나가기 버튼 클릭")
        },
        dismissButtonType: .text("나가기")
    )
}

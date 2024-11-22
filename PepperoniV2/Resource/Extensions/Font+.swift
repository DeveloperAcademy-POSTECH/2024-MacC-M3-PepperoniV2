//
//  Font.swift
//  PepperoniV2
//
//  Created by 변준섭 on 11/21/24.
//

import SwiftUI

struct HakgyoansimSUITModifier: ViewModifier {
    
    /// 폰트 이름 열거형
    enum FontFamily {
        case hakgyoansim
        case suit(FontWeight)
        
        enum FontWeight: String {
            case thin = "SUIT-Thin"
            case extraLight = "SUIT-ExtraLight"
            case light = "SUIT-Light"
            case regular = "SUIT-Regular"
            case medium = "SUIT-Medium"
            case semiBold = "SUIT-SemiBold"
            case bold = "SUIT-Bold"
            case extraBold = "SUIT-ExtraBold"
            case heavy = "SUIT-Heavy"
        }
        
        var name: String {
            switch self {
            case .hakgyoansim:
                return "OTHakgyoansimUndongjangL"
            case .suit(let weight):
                return weight.rawValue
            }
        }
    }
    
    var family: FontFamily
    var size: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.custom(family.name, size: size))
    }
}

extension View {
    
    /// 커스텀 폰트를 적용 후 반환합니다.
    func hakgyoansim(size: CGFloat) -> some View {
        modifier(HakgyoansimSUITModifier(family: .hakgyoansim, size: size))
    }
    
    func suit(_ weight: HakgyoansimSUITModifier.FontFamily.FontWeight, size: CGFloat) -> some View {
        modifier(HakgyoansimSUITModifier(family: .suit(weight), size: size))
    }
}

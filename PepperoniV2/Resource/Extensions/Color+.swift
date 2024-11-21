//
//  Color+.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/20/24.
//

import SwiftUI

extension Color {
    /// 사용 예시
    /// background(.ppBlueGray)
    static let ppWhiteGray = Color(hex: "EEEDF5")
    
    static let ppBlueGray = Color(hex: "DCDAEA")
    
    static let ppLightGray = Color(hex: "ABABAB")
    
    static let ppDarkGray_01 = Color(hex: "767382")
    
    static let ppDarkGray_02 = Color(hex: "313037")
    
    static let ppDarkGray_03 = Color(hex: "232227")
    
    static let ppDarkGray_04 = Color(hex: "141415")
    
    static let ppBlack_01 = Color(hex: "0D0D0D")
    
    static let ppPurple_01 = Color(hex: "7787FF")
    
    static let ppPurple_02 = Color(hex: "6652E7")
    
    static let ppPurple_03 = Color(hex: "AD29FF")
    
    static let ppPink_00 = Color(hex: "FF37C9")
    
    static let ppMint_00 = Color(hex: "3FE9FF")
}

extension Color {
    /// 사용 예시
    /// Color(hex: "FFA800", opacity: 0.1)
    init(hex: String, opacity: Double = 1.0) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xff) / 255
        let green = Double((rgb >> 8) & 0xff) / 255
        let blue = Double((rgb >> 0) & 0xff) / 255
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

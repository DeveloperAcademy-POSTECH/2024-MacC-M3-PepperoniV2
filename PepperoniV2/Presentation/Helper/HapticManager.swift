//
//  HapticManager.swift
//  PepperoniV2
//
//  Created by 변준섭 on 11/28/24.
//

import SwiftUI

class HapticManager {
    
    static let instance = HapticManager()
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    // 커스텀 햅틱 시퀀스
    func customHapticSequence(styles: [UIImpactFeedbackGenerator.FeedbackStyle], delays: [TimeInterval]) {
        guard styles.count == delays.count else {
            print("Error: Styles and delays must have the same count")
            return
        }
        
        for (index, style) in styles.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delays[index]) {
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.impactOccurred()
            }
        }
    }
    
    // 커스텀 타이밍 기반 햅틱 시퀀스 (0.1초 단위)
    func customHapticTiming(sequence: [(UIImpactFeedbackGenerator.FeedbackStyle, TimeInterval)]) {
        for (style, delay) in sequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.impactOccurred()
            }
        }
    }
}

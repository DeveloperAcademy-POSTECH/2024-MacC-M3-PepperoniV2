//
//  RouletteView.swift
//  PepperoniV2
//
//  Created by 변준섭 on 11/19/24.
//

import SwiftUI

class RouletteManager: ObservableObject {
    @Published var players: [Player] = [] {
        didSet {
            // players가 변경될 때 추가 로직을 넣을 수 있음
            print("Players updated, new count: \(players.count)")
        }
    }
    
    var sectorAngle: Double {
        players.isEmpty ? 0 : 360 / Double(players.count)
    }
    
    @Published var rotation: Double = 0 // 룰렛의 현재 회전 각도
    @Published var isSpinning = false
    @Published var selectedItem: Player?
    
    init(players: [Player]) {
        self.players = players
    }
    
    func spinRoulette() {
        guard !isSpinning else { return }
        isSpinning = true
        
        let randomSpin = Double.random(in: 1440...2160) // 룰렛이 몇 바퀴 돌 것인지
        let totalSpin = rotation + randomSpin
        let nearestMultiple = (totalSpin / sectorAngle).rounded() * sectorAngle // 가장 가까운 배수로 조정
        
        rotation = nearestMultiple
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
            HapticManager.instance.customHapticSequence(
                styles: [.medium, .heavy],
                delays: [0.25, 0.35]
            )
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isSpinning = false
            self.selectedItem = self.getSelectedItem() // 결과 업데이트
        }
    }
    
    func getSelectedItem() -> Player {
        let currentAngle = 360 - rotation.truncatingRemainder(dividingBy: 360)
        let sectorCenters = (0..<players.count).map { index in
            sectorAngle * Double(index)
        }
        
        var closestIndex = 0
        if currentAngle <= (360 - sectorAngle){
            closestIndex = sectorCenters.enumerated()
                .min(by: { abs($0.element - currentAngle) < abs($1.element - currentAngle) })?
                .offset ?? 0
        }
        
        return players[closestIndex]
    }
}


struct RouletteTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

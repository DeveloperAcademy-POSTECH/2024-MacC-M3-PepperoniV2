//
//  RouletteView.swift
//  PepperoniV2
//
//  Created by 변준섭 on 11/19/24.
//

import SwiftUI

struct RouletteView: View {
    
    @StateObject private var manager = RouletteManager(players: [
        Player(nickname: "준요", turn: 1, score: 0),
        Player(nickname: "하래", turn: 2, score: 0),
        Player(nickname: "자운드", turn: 3, score: 0),
        Player(nickname: "원", turn: 4, score: 0),
        Player(nickname: "젠", turn: 5, score: 0),
        Player(nickname: "푸딩", turn: 6, score: 0)
    ])
    
    var body: some View {
        VStack {
            if let player = manager.selectedItem {
                Text(player.nickname ?? "")
                    .font(.largeTitle)
            }
            
            RouletteTriangle()
                .fill(Color.black)
                .frame(width: 20, height: 40)
                .padding(20)
            
            ZStack {
                Circle()
                    .fill(.clear)
                    .frame(width: 300, height: 300)
                    .overlay(
                        ZStack {
                            ForEach(manager.players.indices) { index in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(style: StrokeStyle(lineWidth: 2))
                                        .frame(width: 100, height: 50)
                                    Text(manager.players[index].nickname ?? "")
                                }
                                .offset(y: -150)
                                .rotationEffect(.degrees(Double(index) * manager.sectorAngle))
                            }
                        }
                    )
                    .rotationEffect(.degrees(manager.rotation))
                    .animation(.easeOut(duration: manager.isSpinning ? 3 : 0), value: manager.rotation)
            }
            .onTapGesture {
                manager.spinRoulette()
            }
        }
    }
}

class RouletteManager: ObservableObject {
    let players: [Player]
    let sectorAngle: Double
    
    @Published var rotation: Double = 0 // 룰렛의 현재 회전 각도
    @Published var isSpinning = false
    @Published var selectedItem: Player?
    
    init(players: [Player]) {
        self.players = players
        self.sectorAngle = 360 / Double(players.count)
    }
    
    func spinRoulette() {
        guard !isSpinning else { return }
        isSpinning = true
        
        let randomSpin = Double.random(in: 1440...2160) // 룰렛이 몇 바퀴 돌 것인지
        let totalSpin = rotation + randomSpin
        let nearestMultiple = (totalSpin / sectorAngle).rounded() * sectorAngle // 가장 가까운 배수로 조정
        
        rotation = nearestMultiple
        
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

//class HapticManager {
//    static let instance = HapticManager()
//    private var hapticEngine: CHHapticEngine?
//
//    init() {
//        prepareHaptics()
//    }
//
//    private func prepareHaptics() {
//        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
//            print("Haptics not supported on this device.")
//            return
//        }
//        do {
//            hapticEngine = try CHHapticEngine()
//            try hapticEngine?.start()
//        } catch {
//            print("Failed to start haptic engine: \(error.localizedDescription)")
//        }
//    }
//
//    func playCustomHaptic() {
//        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
//        var events = [CHHapticEvent]()
//
//        // 강한 진동 이벤트
//        let sharpTap = CHHapticEvent(
//            eventType: .hapticTransient,
//            parameters: [
//                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
//                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
//            ],
//            relativeTime: 0
//        )
//        events.append(sharpTap)
//
//        do {
//            let pattern = try CHHapticPattern(events: events, parameters: [])
//            let player = try hapticEngine?.makePlayer(with: pattern)
//            try player?.start(atTime: CHHapticTimeImmediate)
//        } catch {
//            print("Failed to play custom haptic: \(error.localizedDescription)")
//        }
//    }
//}

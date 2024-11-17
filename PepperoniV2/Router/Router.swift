//
//  GameRouter.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/17/24.
//

import SwiftUI

public final class Router: ObservableObject {
    @Published public var route = NavigationPath()
    
    public init() {}
    
    /// 새로운 화면으로
    @MainActor
    public func push<T: Hashable>(screen: T) {
        route.append(screen)
    }
    
    /// 이전 화면으로
    @MainActor
    public func pop() {
        route.removeLast()
    }
    
    /// depth 만큼 뒤로 이동
    @MainActor
    public func pop(depth: Int) {
        route.removeLast(depth)
    }
    
    /// 모든 path를 제거
    @MainActor
    public func popToRoot() {
        route = NavigationPath()
    }
    
    /// 현재 화면을 새로운 화면으로 교체
    @MainActor
    public func switchScreen<T: Hashable>(screen: T) {
        guard !route.isEmpty else { return }
        var tempRoute = route
        tempRoute.removeLast()
        tempRoute.append(screen)
        route = tempRoute
    }
}

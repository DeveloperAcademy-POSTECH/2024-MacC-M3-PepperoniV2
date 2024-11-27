//
//  AppDelegate.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/16/24.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    static let anonymousSignInCompleted = Notification.Name("anonymousSignInCompleted")
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Firebase 초기화
        FirebaseApp.configure()
        
        // 익명 인증
        signInAnonymously()
        return true
    }
    
    // 익명 인증 함수
    private func signInAnonymously() {
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                print("Error signing in anonymously: \(error)")
            } else if let user = authResult?.user {
                print("Successfully signed in anonymously with uid: \(user.uid)")
                NotificationCenter.default.post(name: AppDelegate.anonymousSignInCompleted, object: nil)
            }
            
            if let user = Auth.auth().currentUser {
                print("User is signed in with uid: \(user.uid)")
            } else {
                print("User is not signed in.")
            }
        }
    }
}

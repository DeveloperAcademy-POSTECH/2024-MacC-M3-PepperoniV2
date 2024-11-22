//
//  Gradient+.swift
//  PepperoniV2
//
//  Created by Hyun Jaeyeon on 11/21/24.
//

import SwiftUI

extension LinearGradient {
    static var gradient3: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color.ppPurple_03, location: 0),
                .init(color: Color.ppMint_00, location: 0.98)
            ]),
            startPoint: .trailing,
            endPoint: .leading
        )
    }
}

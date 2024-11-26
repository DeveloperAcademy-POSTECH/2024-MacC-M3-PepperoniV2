//
//  FetchDataState.swift
//  PepperoniV2
//
//  Created by Woowon Kang on 11/24/24.
//

import Foundation

class FetchDataState: ObservableObject {
    @Published var isFetchingData: Bool = true
    @Published var errorMessage: String? = nil
}

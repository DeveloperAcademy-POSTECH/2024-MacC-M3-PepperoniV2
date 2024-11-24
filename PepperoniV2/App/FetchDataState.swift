//
//  FetchDataState.swift
//  PepperoniV2
//
//  Created by Woowon Kang on 11/24/24.
//

import Observation

@Observable
class FetchDataState {
    var isFetchingData: Bool = true
    var errorMessage: String? = nil
}

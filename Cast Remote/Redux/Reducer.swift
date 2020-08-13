//
//  Reducer.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/10/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import Combine

struct Reducer<State, Action> {
    typealias Change = (inout State) -> Void
    let reduce: (State, Action) -> AnyPublisher<Change, Never>
}

extension Reducer {
    static func sync(_ fun: @escaping (inout State) -> Void) -> AnyPublisher<Change, Never> {
        return Just(fun).eraseToAnyPublisher()
    }
}

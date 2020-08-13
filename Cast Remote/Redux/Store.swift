//
//  Store.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/10/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import Combine

final class Store<State, Action>: ObservableObject {
    
    @Published private(set) var state: State
    private let reducer: Reducer<State, Action>
    private var cancellables: Set<AnyCancellable> = []
    
    init(initialState: State, reducer: Reducer<State, Action>) {
        self.state = initialState
        self.reducer = reducer
    }
    
    func send(_ action: Action) {
        reducer
            .reduce(state, action)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: perform)
            .store(in: &cancellables)
    }
    
    private func perform(change: Reducer<State, Action>.Change) {
        change(&state)
    }
}

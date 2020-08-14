//
//  ViewModel.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/10/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import Combine

protocol ViewModel: ObservableObject where ObjectWillChangePublisher.Output == Void {
    associatedtype State
    associatedtype Input
    
    var state: State { get }
    func trigger(_ input: Input)
}

extension ViewModel where Input == Never {
    func trigger(_ Input: Never) {}
}

extension ViewModel {
    func eraseToAnyViewModel() -> AnyViewModel<Self.State, Self.Input> {
        return AnyViewModel(self)
    }
}

final class JustViewState<State, Input>: ViewModel {
    
    let state: State
    func trigger(_ input: Input) {}
    
    init(state: State) {
        self.state = state
    }
}

final class AnyViewModel<State, Input>: ObservableObject {
    
    var state: State { wrappedState() }
    
    private let wrappedState: () -> State
    private let wrappedTrigger: (Input) -> Void
    private var viewModelListener: AnyCancellable?
    
    init<VM: ViewModel>(_ viewModel: VM) where VM.State == State, VM.Input == Input {
        self.wrappedState = { viewModel.state }
        self.wrappedTrigger = viewModel.trigger
        
        self.viewModelListener = viewModel.objectWillChange.sink {
            self.objectWillChange.send()
        }
    }
    
    func trigger(_ input: Input) {
        wrappedTrigger(input)
    }
}

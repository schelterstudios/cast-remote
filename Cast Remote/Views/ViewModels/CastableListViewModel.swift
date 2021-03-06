//
//  CastableListViewModel.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/14/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import Combine

class CastableListViewModel: ViewModel {
    
    //private(set) var sessionStatus = CurrentValueSubject<GCKSessionManager.SessionStatus, Never>()
    
    @Published private(set) var state: CastableListState
    private(set) var selectedCastable: Castable?
    
    private var content: CastableListContent {
        get { state.content }
        set { state = CastableListState(title: state.title, content: newValue) }
    }
    
    private let group: ProviderGroup
    private let castService = CastService()
    private var reloadPublisher: AnyCancellable?
    private var castPublisher: AnyCancellable?
    private var castableViewModels: [Castable: CastableRowViewModel] = [:]
    
    init(title: String, group: ProviderGroup) {
        self.group = group
        state = CastableListState(title: title, content: .preinit)
    }
    
    func trigger(_ input: CastableListInput) {
        switch input {
        case .reload(let force) : reload(force: force)
        case .toggle(let row) : toggleCast(castable: row.castable!)
        }
    }
    
    func reload(force: Bool) {
        reloadPublisher?.cancel()
        reloadPublisher = PlatformServices.fetchCastables(force: force, from: group)
            .map{ r -> [(Castable, Int)] in (0..<r.count).map{ (r[$0], $0) } }
            .map{ r -> [CastableRowViewModel] in r.compactMap{ self.viewModel(for: $0.0, index: $0.1) } }
            .map{ CastableListContent.loaded($0) }
            .catch{ Just(CastableListContent.failed($0)) }
            .assign(to: \.content, on: self)
    }
    
    func startCast(castable: Castable) {
        if castable == selectedCastable { return }
        
        if let prev = selectedCastable {
            let vm = viewModel(for: prev)
            vm.selected = false
            vm.status = .none
        }
        
        let vm = viewModel(for: castable)
        vm.selected = true
        vm.status = .connecting
        selectedCastable = castable
        
        castPublisher?.cancel()
        castPublisher = castService.load(castable: castable)
            .sink(receiveCompletion: { r in
                if case Subscribers.Completion.failure(let err) = r {
                    print(err)
                    vm.status = .failed
                }
            }){ vm.status = .casting }
    }
    
    func stopCast() {
        guard let selected = selectedCastable else { return }
        let vm = viewModel(for: selected)
        vm.selected = false
        vm.status = .none
        selectedCastable = nil
        
        castPublisher?.cancel()
        castPublisher = castService.stop()
            .sink(receiveCompletion: { r in
                if case Subscribers.Completion.failure(let err) = r {
                    print(err)
                }
            }){}
    }
    
    private func toggleCast(castable: Castable) {
        if castable == selectedCastable { stopCast() }
        else { startCast(castable: castable) }
    }
    
    private func viewModel(for castable: Castable, index: Int) -> CastableRowViewModel {
        let vm = viewModel(for: castable)
        vm.index = index
        return vm
    }
    
    private func viewModel(for castable: Castable) -> CastableRowViewModel {
        var vm = castableViewModels[castable]
        if vm == nil {
            vm = CastableRowViewModel(castable: castable)
            castableViewModels[castable] = vm
        }
        return vm!
    }
}

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
    private(set) var selectedCastable: TwitchStream?
    
    private var content: CastableListContent {
        get { state.content }
        set { state = CastableListState(content: newValue) }
    }
    
    private let service = TwitchService()
    private let castService = CastService()
    private var reloadPublisher: AnyCancellable?
    private var castPublisher: AnyCancellable?
    private var castableViewModels: [TwitchStream: CastableRowViewModel] = [:]
    
    init() {
        state = CastableListState(content: .preinit)
    }
    
    func trigger(_ input: CastableListInput) {
        switch input {
        case .reload(let force) : reload(force: force)
        case .toggle(let row) : toggleCast(castable: row.castable!)
        }
    }
    
    func reload(force: Bool) {
        let channels = App.shared.pinned?.providers?.array.compactMap{ $0 as? TwitchChannel } ?? []
        reloadPublisher?.cancel()
        reloadPublisher = service.fetchCastables(force: force, channels: channels)
            .map{ self.sort(castables: $0) }
            .map{ r -> [(TwitchStream, Int)] in (0..<r.count).map{ (r[$0], $0) } }
            .map{ r -> [CastableRowViewModel] in r.compactMap{ self.viewModel(for: $0.0, index: $0.1) } }
            .map{ CastableListContent.loaded($0) }
            .catch{ Just(CastableListContent.failed($0)) }
            .assign(to: \.content, on: self)
    }
    
    func startCast(castable: TwitchStream) {
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
                    vm.status = .none
                    vm.selected = false
                    self.selectedCastable = nil
                }
            }){ vm.status = .casting }
    }
    
    func stopCast() {
        guard let selected = selectedCastable else { return }
        let vm = viewModel(for: selected)
        vm.selected = false
        selectedCastable = nil
        
        castPublisher?.cancel()
        castPublisher = castService.stop()
            .sink(receiveCompletion: { r in
                if case Subscribers.Completion.failure(let err) = r {
                    print(err)
                }
            }){ vm.status = .none }
    }
    
    private func toggleCast(castable: TwitchStream) {
        if castable == selectedCastable { stopCast() }
        else { startCast(castable: castable) }
    }
    
    private func sort(castables: [TwitchStream]) -> [TwitchStream] {
        return castables.map{ c -> (TwitchStream, Int) in
            guard let p = c.channel else { return (c, 999) }
            let i = App.shared.pinned?.providers?.index(of: p) ?? 999
            return (c, i)
        }.sorted{ $0.1 < $1.1 }.map{ $0.0 }
    }
    
    private func viewModel(for castable: TwitchStream, index: Int) -> CastableRowViewModel {
        let vm = viewModel(for: castable)
        vm.index = index
        return vm
    }
    
    private func viewModel(for castable: TwitchStream) -> CastableRowViewModel {
        var vm = castableViewModels[castable]
        if vm == nil {
            vm = CastableRowViewModel(castable: castable)
            castableViewModels[castable] = vm
        }
        return vm!
    }
}

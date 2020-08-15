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
    
    @Published private(set) var state: CastableListState
    
    private var content: CastableListContent {
        get { state.content }
        set { state = CastableListState(content: newValue) }
    }
    
    private let service = TwitchService()
    private let castService = CastService()
    private var reloadPublisher: AnyCancellable?
    private var castableViewModels: [TwitchStream: CastableRowViewModel] = [:]
    
    init() {
        state = CastableListState(content: .preinit)
    }
    
    func trigger(_ input: CastableListInput) {
        switch input {
        case .reload(let force) : reload(force: force); break
        case .cast(let castable) : cast(castable: castable); break
        }
    }
    
    func reload(force: Bool) {
        let channels = App.shared.pinned?.providers?.array.compactMap{ $0 as? TwitchChannel } ?? []
        reloadPublisher?.cancel()
        reloadPublisher = service.fetchCastables(force: force, channels: channels)
            .map{ r -> [CastableRowViewModel] in r.compactMap{ self.viewModel(for: $0) } }
            //.map{ self.sort(rows: $0) }
            .map{ CastableListContent.loaded($0) }
            .catch{ Just(CastableListContent.failed($0)) }
            .assign(to: \.content, on: self)
    }
    
    func cast(castable: CastableRowViewModel) {
        guard let source = castable.castable else { return }
        castService.load(castable: source)
    }
    
    private func viewModel(for castable: TwitchStream) -> CastableRowViewModel {
        if let vm = castableViewModels[castable] { return vm }
        let vm = CastableRowViewModel(castable: castable)
        castableViewModels[castable] = vm
        return vm
    }
}

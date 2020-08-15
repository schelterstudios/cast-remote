//
//  ProviderGroupViewModel.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/14/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation

fileprivate extension ProviderGroup {
    var rows: [ProviderRowViewModel] {
        (providers?.array as? [Provider] ?? []).map{ ProviderRowViewModel(provider: $0) }
    }
}

class ProviderGroupViewModel: ViewModel {
    
    @Published private(set) var state: ProviderGroupState
    
    private let group: ProviderGroup
    
    init(title: String, group: ProviderGroup) {
        self.group = group
        let model = PlatformListViewModel(group: group).eraseToAnyViewModel()
        state = ProviderGroupState(title: title, providers: group.rows, platformListModel: model)
    }
    
    func trigger(_ input: ProviderGroupInput) {
        switch input {
        case .reload : reload(); break
        case .moveRows(let fromOffsets, let toOffset) : moveRows(fromOffsets: fromOffsets, toOffset: toOffset); break
        case .deleteRows(let indexSet) : deleteRows(at: indexSet); break
        }
    }
    
    func reload() {
        state = ProviderGroupState(title: state.title, providers: group.rows, platformListModel: state.platformListModel)
    }
    
    func moveRows(fromOffsets: IndexSet, toOffset: Int){
        group.moveProviders(fromOffsets: fromOffsets, toOffset: toOffset)
        AppDelegate.current.saveContext()
        state.providers.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    func deleteRows(at offsets: IndexSet) {
        group.removeFromProviders(at: NSIndexSet(indexSet: offsets))
        AppDelegate.current.saveContext()
        state.providers.remove(atOffsets: offsets)
    }
}

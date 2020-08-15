//
//  ProviderListViewModel.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/11/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI
import Combine

class ProviderListViewModelBase: ViewModel {
    
    let title: String
    let themeColor: Color
    @Published private(set) var state: ProviderListState
    
    fileprivate var content: ProviderListContent {
        get { state.content }
        set { state = ProviderListState(title: title, themeColor: themeColor, content: newValue) }
    }
    
    private let group: ProviderGroup?
    private var providerViewModels: [Provider: ProviderRowViewModel] = [:]
    
    init(title: String, themeColor: Color, group: ProviderGroup?) {
        self.title = title
        self.themeColor = themeColor
        self.group = group
        self.state = ProviderListState(title: title, themeColor: themeColor, content: .preinit)
    }
    
    final func trigger(_ input: ProviderListInput) {
        switch input {
        case .reload(let force) : reload(force: force); break
        case .apply : apply(); break
        }
    }
    
    func reload(force: Bool) {
        if force {
            providerViewModels.forEach{ key, value in
                value.selected = false
            }
        }
    }

    final func apply() {
        guard let group = self.group else { return }
        
        if case ProviderListContent.loaded(let providers) = state.content {
            
            // get selected Providers
            let selected = providers.filter{ $0.selected }.compactMap{ $0.provider }
                        
            // get Providers already stored in group
            let grouped = group.providers?.array as? [Provider] ?? []
            
            // store existing and selected Providers
            group.providers = NSOrderedSet(array: grouped + selected)
            AppDelegate.current.saveContext()
        }
    }
    
    fileprivate func viewModel(for provider: Provider) -> ProviderRowViewModel? {
        if group?.providers?.contains(provider) == true { return nil }
        if let vm = providerViewModels[provider] { return vm }
        let vm = ProviderRowViewModel(provider: provider)
        providerViewModels[provider] = vm
        return vm
    }
    
    fileprivate func sort(rows: [ProviderRowViewModel]) -> [ProviderRowViewModel] {
        rows.sorted { a, b in
            //if a.selected != b.selected { return a.selected }
            return a.displayName.lowercased() < b.displayName.lowercased()
        }
    }
}

class ProviderListViewModel: ProviderListViewModelBase {

    private let service: PlatformService
    private var reloadPublisher: AnyCancellable?

    init(service: PlatformService, group: ProviderGroup) {
        let t: String
        switch service.type {
        case .twitch : t = "Twitch Channels"; break
        }
        
        self.service = service
        super.init(title: t, themeColor: service.type.themeColor, group: group)
    }
    
    override func reload(force: Bool) {
        super.reload(force: force)
        
        // If the view is still on preinit and we're forcing a reload,
        // let's at least show the cached data while fetching.
        if case ProviderListContent.preinit = content, force {
            if let cached = service.cachedProviders, cached.count > 0 {
                content = .loaded(self.sort(rows: cached.compactMap{ self.viewModel(for: $0)}))
            }
        }
        
        reloadPublisher?.cancel()
        reloadPublisher = service.fetchProviders(force: force)
            .map{ r -> [ProviderRowViewModel] in r.compactMap{ self.viewModel(for: $0) } }
            .map{ self.sort(rows: $0) }
            .map{ ProviderListContent.loaded($0) }
            .catch{ Just(ProviderListContent.failed($0)) }
            .assign(to: \.content, on: self)
    }
}

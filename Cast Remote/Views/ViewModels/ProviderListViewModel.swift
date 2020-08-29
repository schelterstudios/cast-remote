//
//  ProviderListViewModel.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/11/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI
import Combine

class ProviderListViewModel: ViewModel {
    
    @Published private(set) var state: ProviderListState
    
    private var content: ProviderListContent {
        get { state.content }
        set { state = ProviderListState(title: state.title, themeColor: state.themeColor, content: newValue) }
    }
    
    private let service: PlatformService
    private let group: ProviderGroup
    
    private var providerViewModels: [Provider: ProviderRowViewModel] = [:]
    private var contentPublisher: AnyCancellable?

    
    init(service: PlatformService, group: ProviderGroup) {
        let title: String
        switch service.type {
        case .twitch : title = "Twitch Channels"
        }
        
        self.service = service
        self.group = group
        self.state = ProviderListState(title: title, themeColor: service.type.themeColor, content: .preinit)
    }
    
    func trigger(_ input: ProviderListInput) {
        switch input {
        case .reload(let force) : reload(force: force)
        case .logOut : logOut()
        case .apply : apply()
        }
    }
    
    func reload(force: Bool) {
        if force {
            providerViewModels.forEach{ key, value in
                value.selected = false
            }
        }
        
        // If the view is still on preinit and we're forcing a reload,
        // let's at least show the cached data while fetching.
        if case ProviderListContent.preinit = content, force {
            if let username = service.cachedUsername, let providers = service.cachedProviders, providers.count > 0 {
                content = .loaded(username, providers.compactMap{ self.viewModel(for: $0) }
                    .sorted{ $0.displayName.lowercased() < $1.displayName.lowercased() })
            }
        }
        
        contentPublisher?.cancel()
        contentPublisher = service.fetchProviders(force: force)
            .map{ r -> (String, [ProviderRowViewModel]) in
                (r.username, r.providers.compactMap{ self.viewModel(for: $0) }
                    .sorted{ $0.displayName.lowercased() < $1.displayName.lowercased() })
            }
            .map{ ProviderListContent.loaded($0.0, $0.1) }
            .catch{ Just(ProviderListContent.failed($0)) }
            .assign(to: \.content, on: self)
    }
    
    func logOut() {
        contentPublisher?.cancel()
        contentPublisher = service.logOut()
            .receive(on: DispatchQueue.main)
            .map{ ProviderListContent.loggedOut }
            .assign(to: \.content, on: self)
    }

    func apply() {

        if case ProviderListContent.loaded(let username, let providers) = state.content {
            
            // get selected Providers
            let selected = providers.filter{ $0.selected }.compactMap{ $0.provider }
                        
            // get Providers already stored in group
            let grouped = group.providers?.array as? [Provider] ?? []
            
            // store existing and selected Providers
            group.providers = NSOrderedSet(array: grouped + selected)
            AppDelegate.current.saveContext()
            
            // display remaining Providers
            content = .loaded(username, providers.filter{ !$0.selected })
        }
    }
    
    private func viewModel(for provider: Provider) -> ProviderRowViewModel? {
        if group.providers?.contains(provider) == true { return nil }
        if let vm = providerViewModels[provider] { return vm }
        let vm = ProviderRowViewModel(provider: provider)
        providerViewModels[provider] = vm
        return vm
    }
}

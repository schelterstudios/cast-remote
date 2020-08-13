//
//  ProviderListViewModel.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/11/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import Combine

protocol ProviderListViewModelDelegate: NSObjectProtocol {
    func providerListViewModel(_ model: ProviderListViewModel, didSelectProvider provider: Provider)
}

class ProviderListViewModelBase: ViewModel {
    
    let title: String
    @Published private(set) var state: ProviderListState
    
    fileprivate var content: ProviderListContent {
        get { state.content }
        set { state = ProviderListState(title: self.title, content: newValue) }
    }
    
    private let group: ProviderGroup?
    private var providerViewModels: [Provider: ProviderRowViewModel] = [:]
    
    init(title: String, group: ProviderGroup?) {
        self.title = title
        self.group = group
        self.state = ProviderListState(title: title, content: .preinit)
    }
    
    final func trigger(_ input: ProviderListInput) {
        switch input {
        case .reload(let force) : reload(force: force); break
        case .apply : apply(); break
        }
    }
    
    func reload(force: Bool) {
        fatalError("reload(force:) method must be overridden")
    }

    final func apply() {
        guard let group = self.group else { return }
        
        if case ProviderListContent.loaded(let providers) = state.content {
            
            // get all listed Providers
            let listed = providers.compactMap{ $0.provider }
            
            // get selected Providers
            let selected = providers.filter{ $0.selected }.compactMap{ $0.provider }
                        
            // get Providers already stored in group
            let grouped = group.providers?.array as? [Provider] ?? []
            
            // only keep the stored Providers that are unlisted
            let unlisted = grouped.filter{ !listed.contains($0) }
                
            // store unlisted and selected Providers
            group.providers = NSOrderedSet(array: unlisted + selected)
            AppDelegate.current.saveContext()
        }
    }
    
    fileprivate func viewModel(for provider: Provider) -> ProviderRowViewModel {
        if let vm = providerViewModels[provider] { return vm }
        let vm = ProviderRowViewModel(provider: provider)
        vm.selected = group?.providers?.contains(provider) == true
        providerViewModels[provider] = vm
        return vm
    }
}

class ProviderListViewModel: ProviderListViewModelBase {

    private let service: ProviderService
    private var reloadPublisher: AnyCancellable?

    init(service: ProviderService, group: ProviderGroup) {
        let t: String
        switch service.type {
        case .twitch : t = "Twitch Channels"; break
        }
        
        self.service = service
        super.init(title: t, group: group)
    }
    
    override func reload(force: Bool) {
        
        // If the view is still on preinit and we're forcing a reload,
        // let's at least show the cached data while fetching.
        if case ProviderListContent.preinit = content, force {
            if let cached = service.cachedProviders, cached.count > 0 {
                content = .loaded(cached.map{ self.viewModel(for: $0)})
            }
        }
        
        reloadPublisher?.cancel()
        reloadPublisher = service.fetchProviders(force: force)
            .map{ r -> [ProviderRowViewModel] in r.map{ self.viewModel(for: $0) } }
            .map{ ProviderListContent.loaded($0) }
            .catch{ Just(ProviderListContent.failed($0)) }
            .assign(to: \.content, on: self)
    }
}

class DemoProviderListViewModel: ProviderListViewModelBase {
    
    var testSuccess: Bool
    private var demoDTOs: [Any]

    init(demoDTOs: [Any], testSuccess: Bool = true) {
        self.demoDTOs = demoDTOs
        self.testSuccess = testSuccess
        super.init(title: "Demo Providers", group: nil)
    }
    
    override func reload(force: Bool) {
        if !testSuccess {
            content = .failed(NSError(domain:"test fail", code: 0, userInfo: nil))
        }
        let providers = demoDTOs.map{ ProviderRowViewModel(demoDTO: $0) }
        content = .loaded(providers)
    }
}

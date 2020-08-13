//
//  ProviderServiceListViewModel.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/12/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation

class ProviderServiceListViewModel: ViewModel {
    
    typealias Input = Never
    @Published private(set) var state: ProviderServiceListState
        
    init(group: ProviderGroup) {
        let services = [TwitchService()]
        state = ProviderServiceListState(services: services.map{ ProviderServiceListViewModel.rowViewModel(for: $0, group: group) })
    }
    
    private static func rowViewModel(for service: ProviderService, group: ProviderGroup) -> ProviderServiceRowViewModel {
        return ProviderServiceRowViewModel(type: service.type,
                                           submodel: ProviderListViewModel(service: service, group: group)
                                            .eraseToAnyViewModel())
    }
}

class DemoProviderServiceListViewModel: ViewModel {
    
    typealias Input = Never
    @Published private(set) var state: ProviderServiceListState
    
    init() {
        state = ProviderServiceListState(services: [ProviderServiceRowViewModel(type: .twitch)])
    }
}

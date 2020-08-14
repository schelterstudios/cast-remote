//
//  PlatformListViewModel.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/12/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation

class PlatformListViewModel: ViewModel {
    
    typealias Input = Never
    @Published private(set) var state: PlatformListState
        
    init(group: ProviderGroup) {
        let services = [TwitchService()]
        state = PlatformListState(platforms: services.map{ PlatformListViewModel.rowViewModel(for: $0, group: group) })
    }
    
    private static func rowViewModel(for service: PlatformService, group: ProviderGroup) -> PlatformRowViewModel {
        return PlatformRowViewModel(type: service.type,
                                    submodel: ProviderListViewModel(service: service, group: group)
                                        .eraseToAnyViewModel())
    }
}

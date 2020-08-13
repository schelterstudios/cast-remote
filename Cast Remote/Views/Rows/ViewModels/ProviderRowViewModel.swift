//
//  ProviderViewModel.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/12/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation

class ProviderRowViewModel: ObservableObject, Identifiable {
    
    let id = UUID()
    
    @Published var selected: Bool = false
    
    var displayName: String {
        provider?.displayName
            ?? (demoDTO as? TwitchChannelDTO)?.displayName
            ?? "[MISSING]"
    }
    
    var thumbURL: URL? {
        if let provider = self.provider { return provider.thumbURL }
        if let dto = demoDTO as? TwitchChannelDTO { return URL(string: dto.thumbRAW) }
        return nil
    }
    
    var source: Any? { provider ?? demoDTO }
    
    let provider: Provider?
    
    private let demoDTO: Any?
    
    init(provider: Provider) {
        self.provider = provider
        self.demoDTO = nil
    }
    
    init(demoDTO: Any) {
        self.provider = nil
        self.demoDTO = demoDTO
    }
    
    func toggleSelect() {
        selected = !selected
    }
}

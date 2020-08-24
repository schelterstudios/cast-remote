//
//  ProviderViewModel.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/12/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import SwiftUI

extension PlatformType {
    
    var themeColor: Color {
        switch self {
        case .twitch : return Color("twitch")
        }
    }
    
    var icon: UIImage {
        switch self {
        case .twitch : return UIImage(named: "twitch.icon")!
        }
    }
}

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
    
    var themeColor: Color {
        provider?.platform?.type.themeColor ?? .black
    }
    
    var icon: UIImage? {
        provider?.platform?.type.icon
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

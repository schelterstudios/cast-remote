//
//  PlatformRowViewModel.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/12/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI
import UIKit

extension PlatformType {
    
    var displayName: String {
        switch self {
        case .twitch : return "Twitch"
        }
    }
    
    var logo: UIImage {
        switch self {
        case .twitch : return #imageLiteral(resourceName: "twitch")
        }
    }
}

class PlatformRowViewModel: Identifiable {
    
    let id = UUID()
        
    var displayName: String { type.displayName }
    var logo: UIImage { type.logo }
    
    let submodel: AnyViewModel<ProviderListState, ProviderListInput>
    private let type: PlatformType
    
    init(type: PlatformType, submodel: AnyViewModel<ProviderListState, ProviderListInput>) {
        self.type = type
        self.submodel = submodel
    }
    
    init(type: PlatformType) {
        self.type = type
        let state = ProviderListState(title: "DEMO", themeColor: Color.green, content: .preinit)
        self.submodel = JustViewState<ProviderListState, ProviderListInput>(state: state).eraseToAnyViewModel()
    }
}

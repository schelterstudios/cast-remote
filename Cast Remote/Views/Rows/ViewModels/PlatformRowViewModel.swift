//
//  PlatformRowViewModel.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/12/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI
import UIKit

class PlatformRowViewModel: Identifiable {
    
    let id = UUID()
        
    var displayName: String {
        switch type {
        case .twitch : return "Twitch"
        }
    }
    
    var logo: UIImage {
        switch type {
        case .twitch : return #imageLiteral(resourceName: "Logo-Twitch")
        }
    }
    
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

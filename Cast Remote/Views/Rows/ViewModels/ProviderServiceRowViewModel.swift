//
//  ProviderServiceRowViewModel.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/12/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import UIKit

class ProviderServiceRowViewModel: Identifiable {
    
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
    private let type: Service.ServiceType
    
    init(type: Service.ServiceType, submodel: AnyViewModel<ProviderListState, ProviderListInput>) {
        self.type = type
        self.submodel = submodel
    }
    
    init(type: Service.ServiceType) {
        self.type = type
        let state = ProviderListState(title: "DEMO", content: .preinit)
        self.submodel = NullViewModel<ProviderListState, ProviderListInput>(state: state).eraseToAnyViewModel()
    }
}

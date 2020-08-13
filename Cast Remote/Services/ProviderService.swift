//
//  ProviderService.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/11/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import Combine

protocol ProviderService {
    var type: Service.ServiceType { get }
    var cachedProviders: [Provider]? { get }
    
    func fetchProviders(force: Bool) -> AnyPublisher<[Provider], Error>
}

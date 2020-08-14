//
//  PlatformService.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/11/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import Combine

enum PlatformType: String {
    case twitch = "twitch"
}

protocol PlatformService {
    var type: PlatformType { get }
    var cachedProviders: [Provider]? { get }
    
    func fetchProviders(force: Bool) -> AnyPublisher<[Provider], Error>
    //func fetchCastables() -> AnyPublisher<[
}

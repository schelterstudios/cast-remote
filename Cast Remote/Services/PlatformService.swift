//
//  PlatformService.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/11/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import Combine

enum PlatformType: String {
    case twitch = "twitch"
}

enum ServiceError: Error {
    case unauthorized
    case missingUser
}

class PlatformServices {
    
    private static var _services: [PlatformService]?
    static var services: [PlatformService] {
        if _services == nil {
            _services = [TwitchService()]
        }
        return _services!
    }
    
    static func service(by type: PlatformType) -> PlatformService {
        return PlatformServices.services.first{ $0.type == type }!
    }
    
    static func fetchCastables(force: Bool, from group: ProviderGroup) -> AnyPublisher<[Castable], Error> {
        let publishers = PlatformServices.services.map{ $0.fetchCastables(force: force, from: group) }
        return Publishers.MergeMany(publishers)
            .collect()
            .map{ $0.reduce([Castable]()){ $0 + $1 } }
            .map{ PlatformServices.sort(castables: $0, group: group) }
            .eraseToAnyPublisher()
    }
    
    static private func sort(castables: [Castable], group: ProviderGroup) -> [Castable] {
        return castables.map{ c -> (Castable, Int) in
            guard let p = c.provider else { return (c, 999) }
            let i = group.allProviders.firstIndex(of: p) ?? 999
            return (c, i)
        }.sorted{ $0.1 < $1.1 }.map{ $0.0 }
    }
}

protocol PlatformService {
    var type: PlatformType { get }
    var cachedUsername: String? { get }
    var cachedProviders: [Provider]? { get }
    
    /// Returns a Publisher for an array of Provider objects
    /// - Parameters:
    ///   - force: A flag that forces refresh (otherwise defaults to cache)
    func fetchProviders(force: Bool) -> AnyPublisher<(username: String, providers:[Provider]), Error>
    
    func fetchCastables(force: Bool, from group: ProviderGroup) -> AnyPublisher<[Castable], Error>
    
    func logOut() -> AnyPublisher<Void, Never>
}

class PlatformServiceBase: PlatformService {

    let type: PlatformType
    
    var cachedUsername: String? {
        model.username
    }
    
    var cachedProviders: [Provider]? {
        model.providers?.allObjects as? [Provider]
    }
    
    /// CoreData object that can serve as a cache
    let model: Platform
    
    init(type: PlatformType) {
        self.type = type
        model = Platform.model(type: type)
    }
    
    func fetchProviders(force: Bool) -> AnyPublisher<(username: String, providers:[Provider]), Error> {
        if let username = cachedUsername, let providers = cachedProviders, (providers.count > 0 && !force) {
            return Just((username: username, providers: providers))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return forceFetchProviders()
    }
    
    func forceFetchProviders() -> AnyPublisher<(username: String, providers:[Provider]), Error> {
        fatalError("PlatformServiceBase.forceFetchProviders() is abstract!")
    }
    
    func fetchCastables(force: Bool, from group: ProviderGroup) -> AnyPublisher<[Castable], Error> {
        let providers = group.providers(from: type)
        
        let cached = providers.compactMap{ $0.castables?.allObjects as? [Castable] }.reduce([]){ $0 + $1 }
        if cached.count > 0 && !force {
            return Just(cached)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
        
        return forceFetchCastables(from: providers)
    }
    
    func forceFetchCastables(from providers: [Provider]) -> AnyPublisher<[Castable], Error> {
        fatalError("PlatformServiceBase.forceFetchCastables(:) is abstract!")
    }
    
    func logOut() -> AnyPublisher<Void, Never> {
        fatalError("PlatformServiceBase.logOut() is abstract!")
    }
}

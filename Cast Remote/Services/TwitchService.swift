//
//  TwitchService.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/9/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import Combine
import CoreData

fileprivate let KRAKEN = "https://api.twitch.tv/kraken"
fileprivate let USER_ID = "39531886"

class TwitchService: PlatformService {
    
    let type = PlatformType.twitch
    
    var cachedProviders: [Provider]? {
        model.providers?.allObjects as? [Provider]
    }
    
    private struct FollowsResultDTO: Decodable {
        let follows: [FollowDTO]
    }
   
    private struct FollowDTO: Decodable {
        let channel: TwitchChannelDTO
    }
    
    private struct StreamsResultDTO: Decodable {
        let streams: [TwitchStreamDTO]
    }
    
    /// CoreData object that can serve as a cache
    private let model: Platform = Platform.model(type: .twitch)
    
    /// Returns a Publisher for an array of Provider objects
    /// - Parameters:
    ///   - force: A flag that forces refresh (otherwise defaults to cache)
    func fetchProviders(force: Bool) -> AnyPublisher<[Provider], Error> {
        
        if let cached = cachedProviders, (cached.count > 0 && !force) {
            return Just(cached)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let request = createRequest(KRAKEN, "users", USER_ID, "follows", "channels")
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap{ element -> Data in
                guard let response = element.response as? HTTPURLResponse,
                    response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: FollowsResultDTO.self, decoder: JSONDecoder())
            .map{ r -> [TwitchChannelDTO] in r.follows.map{ $0.channel } }
            .receive(on: DispatchQueue.main)
            .map{ r -> [Provider] in
                let providers = r.map{ TwitchChannel.model(dto: $0) as Provider }
                // prune out unfollowed providers from cache
                if let cachelist = self.model.providers {
                    let unfollowed = cachelist.filter{ !providers.contains($0 as! Provider) }
                    unfollowed.forEach{ ($0 as? NSManagedObject)?.delete() }
                }
                AppDelegate.current.saveContext()
                return providers
            }
            .eraseToAnyPublisher()
    }
    
    func fetchCastables(force: Bool, channels: [TwitchChannel]) -> AnyPublisher<[TwitchStream], Error> {
        let params = ["channel": channels.reduce(""){ $0 + "," + $1.channelID! }]
        let request = createRequest(KRAKEN, "streams").addURLParams(params)
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap{ element -> Data in
                guard let response = element.response as? HTTPURLResponse,
                    response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: StreamsResultDTO.self, decoder: JSONDecoder())
            .map{ r -> [TwitchStreamDTO] in r.streams }
            .receive(on: DispatchQueue.main)
            .map{ r -> [TwitchStream] in
                let castables = r.map{ TwitchStream.model(dto: $0) }
                AppDelegate.current.saveContext()
                return castables
            }
            .eraseToAnyPublisher()
    }
    
    private func createRequest(_ urlStr: String, _ sub:Any...) -> URLRequest {
        let str = sub.reduce(urlStr) {$0 + "/\($1)"}
        var request = URLRequest(url: URL(string: str)!)
        request = addHeaders(request: request)
        return request
    }
    
    private func addHeaders(request: URLRequest) -> URLRequest {
        var mrequest = request
        mrequest.addValue("n33nlepetq5rw1ilhhqsllj9vcmbxt", forHTTPHeaderField: "Client-ID")
        mrequest.addValue("application/vnd.twitchtv.v5+json", forHTTPHeaderField: "Accept")
        return mrequest
    }
}

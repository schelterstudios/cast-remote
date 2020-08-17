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
import OAuthSwift

fileprivate let CLIENT_ID = "n33nlepetq5rw1ilhhqsllj9vcmbxt"
fileprivate let CLIENT_SECRET = "flh79mbcg9h4a5lf6l70x61imkpbqr"
fileprivate let KRAKEN = "https://api.twitch.tv/kraken"
fileprivate let HELIX = "https://api.twitch.tv/helix"
fileprivate let USER_ID = "39531886"

class TwitchService: PlatformService {
    
    let type = PlatformType.twitch
    
    var cachedProviders: [Provider]? {
        model.providers?.allObjects as? [Provider]
    }
    
    private struct UsersResultDTO: Decodable {
        let data: [TwitchUserDTO]
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
    
    func fetchUser() -> AnyPublisher<User, Error> {
        
        if let user = model.user {
            return Just(user)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return getBearer()
            .flatMap{ bearer in
                self.fetchUser(bearer: bearer).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func getBearer() -> AnyPublisher<String, Error> {
        let oauth2 = OAuth2Swift(consumerKey: CLIENT_ID,
                                 consumerSecret: CLIENT_SECRET,
                                 authorizeUrl: "https://id.twitch.tv/oauth2/authorize",
                                 responseType: "token")
        
        return oauth2.authorizePublisher(callbackURL: "cast-remote://oauth-callback/twitch", scope: "user:read:email")
            .map{ (credential, response, params) in credential.oauthToken }
            .mapError{ $0 as Error }
            .eraseToAnyPublisher()
    }
    
    private func fetchUser(bearer: String) -> AnyPublisher<User, Error> {
        let request = createRequest(HELIX, "users").addToken(bearer: bearer)
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap{ element -> Data in
                guard let response = element.response as? HTTPURLResponse,
                    response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: UsersResultDTO.self, decoder: JSONDecoder())
            .tryMap{ r -> TwitchUserDTO in
                guard let dto = r.data.first else {
                    throw ServiceError.missingUser
                }
                return dto
            }
            .receive(on: DispatchQueue.main)
            .map{ r -> User in
                let user = self.model.createUser(dto: r)
                AppDelegate.current.saveContext()
                return user
            }
            .eraseToAnyPublisher()
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
        
        return fetchUser()
            .flatMap{ self.fetchProviders(user: $0).eraseToAnyPublisher() }
            .eraseToAnyPublisher()
    }
    
    private func fetchProviders(user: User) -> AnyPublisher<[Provider], Error> {
        let request = createRequest(KRAKEN, "users", user.id, "follows", "channels")
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
        mrequest.addValue(CLIENT_ID, forHTTPHeaderField: "Client-ID")
        mrequest.addValue("application/vnd.twitchtv.v5+json", forHTTPHeaderField: "Accept")
        return mrequest
    }
}

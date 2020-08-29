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

class TwitchService: PlatformServiceBase {
    
    private struct UsersResultDTO: Decodable {
        let data: [UserDTO]
    }
    
    private struct UserDTO: Decodable {
        let id: String
        let displayName: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case displayName = "display_name"
        }
    }
    
    typealias User = (userID: String, username: String)
    
    private struct FollowsResultDTO: Decodable {
        let follows: [FollowDTO]
    }
   
    private struct FollowDTO: Decodable {
        let channel: TwitchChannelDTO
    }
    
    private struct StreamsResultDTO: Decodable {
        let streams: [TwitchStreamDTO]
    }
    
    init() {
        super.init(type: .twitch)
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
    
    private func fetchUser() -> AnyPublisher<User, Error> {
        if let userID = (model as? TwitchPlatform)?.userID,
            let username = model.username {
            
            return Just((userID: userID, username: username))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return getBearer()
            .flatMap{ bearer in
                self.fetchUser(bearer: bearer).eraseToAnyPublisher()
            }
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
            .tryMap{ r -> UserDTO in
                guard let dto = r.data.first else {
                    throw ServiceError.missingUser
                }
                return dto
            }
            .receive(on: DispatchQueue.main)
            .map{ r -> User in
                self.model.username = r.displayName
                (self.model as? TwitchPlatform)?.userID = r.id
                AppDelegate.current.saveContext()
                return (userID: r.id, username: r.displayName)
            }
            .eraseToAnyPublisher()
    }
    
    override func forceFetchProviders() -> AnyPublisher<(username: String, providers:[Provider]), Error> {
        return fetchUser()
            .flatMap{ self.forceFetchProviders(user: $0).eraseToAnyPublisher() }
            .eraseToAnyPublisher()
    }
    
    private func forceFetchProviders(user: User) -> AnyPublisher<(username: String, providers:[Provider]), Error> {
        let request = createRequest(KRAKEN, "users", user.userID, "follows", "channels")
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
            .map{ r -> (username: String, providers:[Provider]) in
                let providers = r.map{ TwitchChannel.model(dto: $0) as Provider }
                
                // prune out unfollowed providers from cache
                if let cache = self.cachedProviders {
                    let unfollowed = cache.filter{ !providers.contains($0) }
                    unfollowed.forEach{ $0.delete() }
                }
                
                AppDelegate.current.saveContext()
                return (username: user.username, providers: providers)
            }
            .eraseToAnyPublisher()
    }
    
    override func forceFetchCastables(from providers: [Provider]) -> AnyPublisher<[Castable], Error> {
        let params = ["channel": providers.compactMap{ $0 as? TwitchChannel }.reduce(""){ $0 + "," + $1.channelID! }]
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
            .map{ r -> [Castable] in
                let castables = r.map{ TwitchStream.model(dto: $0) as Castable }
                
                // prune out old streams from cache
                let cache = providers.compactMap{ $0.castables?.allObjects as? [Castable] }.reduce([]){ $0 + $1 }
                let oldCastables = cache.filter{ !castables.contains($0) }
                oldCastables.forEach{ $0.delete() }
                
                AppDelegate.current.saveContext()
                return castables
            }
            .eraseToAnyPublisher()
    }
    
    override func logOut() -> AnyPublisher<Void, Never> {
        self.model.username = nil
        (self.model as? TwitchPlatform)?.userID = nil
        cachedProviders?.forEach{ $0.delete() }
        AppDelegate.current.saveContext()
        return Just(()).eraseToAnyPublisher()
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

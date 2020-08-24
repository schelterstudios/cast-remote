//
//  OAuth2Swift+Publishers.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/16/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import Combine
import OAuthSwift

extension OAuth2Swift {
    
    func authorizePublisher(callbackURL: URLConvertible?, scope: String, state: String = "",
                            parameters: Parameters = [:], headers: OAuthSwift.Headers? = nil) -> AuthorizePublisher {
        
        return AuthorizePublisher(oauth2: self, callbackURL: callbackURL, scope: scope,
                                  state: state, parameters: parameters, headers: headers)
    }
    
    struct AuthorizePublisher: Publisher {
        typealias Output = TokenSuccess
        typealias Failure = OAuthSwiftError
        
        private let oauth2: OAuth2Swift
        private let callbackURL: URLConvertible?
        private let scope: String
        private let state: String
        private let parameters: Parameters
        private let headers: OAuthSwift.Headers?
        
        fileprivate init(oauth2: OAuth2Swift, callbackURL: URLConvertible?, scope: String,
             state: String = "", parameters: Parameters = [:], headers: OAuthSwift.Headers? = nil) {
            
            self.oauth2 = oauth2
            self.callbackURL = callbackURL
            self.scope = scope
            self.state = state
            self.parameters = parameters
            self.headers = headers
        }
        
        func receive<S: Subscriber>(subscriber: S) where Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = OAuth2TokenSuccessSubscription(oauth2: oauth2, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
            subscription.authorize(callbackURL: callbackURL, scope: scope, state: state,
                                   parameters: parameters, headers: headers)
        }
    }
    
    private class OAuth2TokenSuccessSubscription<S: Subscriber>: Subscription
        where S.Input == TokenSuccess, S.Failure == OAuthSwiftError {
        
        private let oauth2: OAuth2Swift
        private var handle: OAuthSwiftRequestHandle?
        private var subscriber: S?
        
        init(oauth2: OAuth2Swift, subscriber: S) {
            self.oauth2 = oauth2
            self.subscriber = subscriber
        }
        
        func authorize(callbackURL: URLConvertible?, scope: String, state: String,
                       parameters: Parameters = [:], headers: OAuthSwift.Headers? = nil) {
            
            handle?.cancel()
            
            handle = oauth2.authorize(withCallbackURL: callbackURL,scope: scope, state: state,
                                      parameters: parameters, headers: headers) { result in
                
                switch result {
                case .success(let success) :
                    _ = self.subscriber?.receive(success)
                    
                case .failure(let error) :
                    _ = self.subscriber?.receive(completion: Subscribers.Completion.failure(error))
                }
            }
        }
        
        func cancel() {
            handle?.cancel()
            subscriber = nil
        }
            
        func request(_ demand: Subscribers.Demand) {}
    }
}

//
//  GCKSessionManager+Publishers.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/16/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import GoogleCast
import Combine

extension GCKSessionManager {

    var currentSessionPublisher: CurrentSessionPublisher {
        return CurrentSessionPublisher(manager: self)
    }
    
    struct CurrentSessionPublisher: Publisher {
        typealias Output = GCKSession?
        typealias Failure = Error
        
        private let manager: GCKSessionManager
        
        fileprivate init(manager: GCKSessionManager) {
            self.manager = manager
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = GCKSessionManagerSessionSubscription(manager: manager, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
            subscription.start()
        }
    }
    
    private class GCKSessionManagerSessionSubscription<S: Subscriber>: NSObject, Subscription, GCKSessionManagerListener
        where S.Input == GCKSession?, S.Failure == Error {
        
        private let manager: GCKSessionManager
        private var subscriber: S?
        
        init(manager: GCKSessionManager, subscriber: S) {
            self.manager = manager
            self.subscriber = subscriber
        }
        
        func start() {
            manager.add(self)
            if let session = manager.currentSession, session.connectionState == GCKConnectionState.connected {
                _ = subscriber?.receive(session)
            }
        }
        
        func stop() {
            manager.remove(self)
        }
        
        func cancel() {
            subscriber = nil
            stop()
        }
            
        func request(_ demand: Subscribers.Demand) {}
        
        func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
            _ = subscriber?.receive(session)
        }
        
        func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKSession, withError error: Error) {
            _ = subscriber?.receive(completion: Subscribers.Completion.failure(error))
        }
        
        func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKSession, withError error: Error?) {
            _ = subscriber?.receive(nil)
        }
    }
}

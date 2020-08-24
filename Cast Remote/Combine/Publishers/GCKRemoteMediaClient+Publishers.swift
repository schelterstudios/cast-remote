//
//  GCKRemoteMediaClient+Publishers.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/15/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import GoogleCast
import Combine

extension GCKRemoteMediaClient {
    
    func loadMediaPublisher(mediaInfo: GCKMediaInformation) -> LoadMediaPublisher {
        return LoadMediaPublisher(mediaClient: self, mediaInfo: mediaInfo)
    }
    
    func stopPublisher() -> StopPublisher {
        return StopPublisher(mediaClient: self)
    }
    
    struct LoadMediaPublisher: Publisher {
        typealias Output = Void
        typealias Failure = Error
        
        private let mediaClient: GCKRemoteMediaClient
        private let mediaInfo: GCKMediaInformation
        
        fileprivate init(mediaClient: GCKRemoteMediaClient, mediaInfo: GCKMediaInformation) {
            self.mediaClient = mediaClient
            self.mediaInfo = mediaInfo
        }
        
        func receive<S: Subscriber>(subscriber: S) where Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = RemoteMediaClientSubscription(mediaClient: mediaClient, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
            subscription.loadMedia(mediaInfo: mediaInfo)
        }
    }
    
    struct StopPublisher: Publisher {
        typealias Output = Void
        typealias Failure = Error
        
        private let mediaClient: GCKRemoteMediaClient
        
        fileprivate init(mediaClient: GCKRemoteMediaClient) {
            self.mediaClient = mediaClient
        }
        
        func receive<S: Subscriber>(subscriber: S) where Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = RemoteMediaClientSubscription(mediaClient: mediaClient, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
            subscription.stop()
        }
    }
    
    private class RemoteMediaClientSubscription<S: Subscriber>: NSObject, Subscription, GCKRequestDelegate
        where S.Input == Void, S.Failure == Error {
        
        private let mediaClient: GCKRemoteMediaClient
        private var subscriber: S?
        
        init(mediaClient: GCKRemoteMediaClient, subscriber: S) {
            self.mediaClient = mediaClient
            self.subscriber = subscriber
        }
        
        func loadMedia(mediaInfo: GCKMediaInformation) {
            mediaClient.loadMedia(mediaInfo).delegate = self
        }
        
        func stop() {
            mediaClient.stop().delegate = self
        }
        
        func cancel() {
            subscriber = nil
        }
            
        func request(_ demand: Subscribers.Demand) {}
        
        func requestDidComplete(_ request: GCKRequest) {
            _ = subscriber?.receive()
        }
        
        func request(_ request: GCKRequest, didFailWithError error: GCKError) {
            _ = subscriber?.receive(completion: Subscribers.Completion.failure(error))
        }
        
        func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
            _ = subscriber?.receive(completion: Subscribers.Completion.failure(CastService.CastError.aborted(abortReason)))
        }
    }
}

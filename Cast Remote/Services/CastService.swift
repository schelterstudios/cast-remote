//
//  CastService.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/14/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import GoogleCast
import Combine

fileprivate let CONVERTER = "https://pwn.sh/tools/streamapi.py"

class CastService {
    
    private struct ConverterResultDTO: Decodable {
        let success: Bool
        let error: String?
        let urls: ConverterURLDTO?
    }
    
    private struct ConverterURLDTO: Decodable {
        let high: String?
        let medium: String?
        let low: String?
        let tiny: String?
        var best: String? { high ?? medium ?? low ?? tiny }
        
        enum CodingKeys: String, CodingKey {
            case high = "1080p60"
            case medium = "720p60"
            case low = "720p"
            case tiny = "480p"
        }
    }
    
    enum CastError: Error {
        case failed(String)
        case missingResult
        case missingParameter
        case missingSession
        case aborted(GCKRequestAbortReason)
    }
    
    func load(castable: Castable) -> AnyPublisher<Void, Error> {
        return convert(castable: castable)
            .map{ self.mediaInfo(for: castable, url: $0) }
            .flatMap{ self.load(mediaInfo: $0) }
            .eraseToAnyPublisher()
    }
    
    func load(mediaInfo: GCKMediaInformation) -> AnyPublisher<Void, Error> {
        return GCKCastContext.sharedInstance().sessionManager.currentSessionPublisher
            .tryMap{ session -> GCKRemoteMediaClient in
                guard let client = session?.remoteMediaClient else {
                    throw CastError.missingSession
                }
                return client
            }
            .flatMap{ $0.loadMediaPublisher(mediaInfo: mediaInfo).eraseToAnyPublisher() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func stop() -> AnyPublisher<Void, Never> {
        return GCKCastContext.sharedInstance().sessionManager.currentSessionPublisher
            .tryMap{ session -> GCKRemoteMediaClient in
                guard let client = session?.remoteMediaClient else {
                    throw CastError.missingSession
                }
                return client
            }
            .flatMap{ $0.stopPublisher().eraseToAnyPublisher() }
            .catch{ _ in return Empty<Void, Never>(completeImmediately: true) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func convert(castable: Castable) -> AnyPublisher<URL, Error> {
        if let url = castable.castURL {
            return Just(url)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let sourceRAW: String?
        
        if let twitchChannel = castable.provider as? TwitchChannel {
            sourceRAW = twitchChannel.urlRAW
        
        } else {
            sourceRAW = nil
        }
        
        if sourceRAW == nil {
            return Fail<URL, Error>(error: CastError.missingParameter).eraseToAnyPublisher()
        }
        
        let request = URLRequest(url: URL(string: CONVERTER)!).addURLParams(["url": sourceRAW!])
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap{ element -> Data in
                guard let response = element.response as? HTTPURLResponse,
                    response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: ConverterResultDTO.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .tryMap{ r -> URL in
                if !r.success { throw CastError.failed(r.error ?? "Unknown reason") }
                guard let urlstr = r.urls?.best, let url = URL(string: urlstr) else {
                    throw CastError.missingResult
                }
                castable.castURL = url
                AppDelegate.current.saveContext()
                return url
            }
            .eraseToAnyPublisher()
    }
    
    private func mediaInfo(for castable: Castable, url: URL) -> GCKMediaInformation {
        let metadata = GCKMediaMetadata()
        
        if let title = castable.title {
            metadata.setString(title, forKey: kGCKMetadataKeyTitle)
        }
        if let subtitle = castable.subtitle {
            metadata.setString(subtitle, forKey: kGCKMetadataKeySubtitle)
        }
        if let previewURL = castable.previewURL {
            metadata.addImage(GCKImage(url: previewURL, width: 640, height: 360))
        }
        
        let mediaInfoBuilder = GCKMediaInformationBuilder.init(contentURL: url)
        mediaInfoBuilder.streamType = GCKMediaStreamType.live
        mediaInfoBuilder.contentType = "video/mp4"
        mediaInfoBuilder.metadata = metadata
        return mediaInfoBuilder.build()
    }
}

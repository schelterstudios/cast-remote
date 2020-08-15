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

class CastService: NSObject, GCKRequestDelegate {
    
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
    
    enum ConverterError: Error {
        case failed(String)
        case missingResult
        case missingParameter
    }
    
    private var convertPublisher: AnyCancellable?
    
    func load(castable: TwitchStream) {//}-> AnyPublisher<Bool, Error> z{
        convertPublisher?.cancel()
        convertPublisher = convert(castable: castable)
            .sink(receiveCompletion: { completion in
                if case .failure(let err) = completion {
                    print("ERROR:",err)
                }
            }){ url in
                let mediaInfoBuilder = GCKMediaInformationBuilder.init(contentURL: url)
                mediaInfoBuilder.streamType = GCKMediaStreamType.live;
                mediaInfoBuilder.contentType = "video/mp4"
                //mediaInfoBuilder.metadata = metadata
                let info = mediaInfoBuilder.build()
                self.load(mediaInfo: info)
            }
        }
    
    func load(mediaInfo: GCKMediaInformation) {//} -> AnyPublisher<Bool, Error> {
        if let request = GCKCastContext.sharedInstance().sessionManager.currentSession?.remoteMediaClient?.loadMedia(mediaInfo) {
            request.delegate = self
        }
    }
    
    func convert(castable: TwitchStream) -> AnyPublisher<URL, Error> {
        guard let castableRAW = castable.channel?.urlRAW else {
            return Fail<URL, Error>(error: ConverterError.missingParameter).eraseToAnyPublisher()
        }
        
        let request = URLRequest(url: URL(string: CONVERTER)!).addURLParams(["url": castableRAW])
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap{ element -> Data in
                guard let response = element.response as? HTTPURLResponse,
                    response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: ConverterResultDTO.self, decoder: JSONDecoder())
            .tryMap{ r -> URL in
                if !r.success { throw ConverterError.failed(r.error ?? "Unknown reason") }
                guard let urlstr = r.urls?.best, let url = URL(string: urlstr) else {
                    throw ConverterError.missingResult
                }
                return url
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func requestDidComplete(_ request: GCKRequest) {
        print("SUCCESS")
    }
    
    func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        print("ABORT")
    }
    
    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        print("FAIL", error)
    }
}

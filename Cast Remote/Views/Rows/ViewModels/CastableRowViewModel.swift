//
//  CastableRowViewModel.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/14/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation

class CastableRowViewModel: Identifiable {
    
    let id = UUID()
    
    var title: String {
        if let stream = self.stream {
            return "\(stream.channel?.displayName ?? "Unknown") streaming \(stream.game ?? "")"
        } else if let dto = self.demoDTO {
            return "\(dto.channel.displayName) streaming \(dto.game)"
        }
        return ""
    }
    
    var subtitle: String? { stream?.channel?.status ?? demoDTO?.channel.status }
    
    var previewURL: URL? {
        if let stream = self.stream {
            return stream.previewURL
        } else if let raw = demoDTO?.preview.mediumRAW {
            return URL(string: raw)
        }
        return nil
    }
    
    var viewCount: Int {
        if let stream = self.stream {
            return Int(stream.viewCount)
        } else {
            return demoDTO?.viewCount ?? 0
        }
    }
    
    private let stream: TwitchStream?
    private let demoDTO: TwitchStreamDTO?
    
    init(stream: TwitchStream) {
        self.stream = stream
        self.demoDTO = nil
    }
    
    init(demoDTO: TwitchStreamDTO) {
        self.stream = nil
        self.demoDTO = demoDTO
    }
}


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
        if let stream = self.castable {
            return "\(stream.channel?.displayName ?? "Unknown") on \(stream.game ?? "")"
        } else if let dto = self.demoDTO {
            return "\(dto.channel.displayName) on \(dto.game)"
        }
        return ""
    }
    
    var subtitle: String? { castable?.channel?.status ?? demoDTO?.channel.status }
    
    var previewURL: URL? {
        if let stream = self.castable {
            return stream.previewURL
        } else if let raw = demoDTO?.preview.mediumRAW {
            return URL(string: raw)
        }
        return nil
    }
    
    var viewCount: Int {
        if let stream = self.castable {
            return Int(stream.viewCount)
        } else {
            return demoDTO?.viewCount ?? 0
        }
    }
    
    let castable: TwitchStream?
    private let demoDTO: TwitchStreamDTO?
    
    init(castable: TwitchStream) {
        self.castable = castable
        self.demoDTO = nil
    }
    
    init(demoDTO: TwitchStreamDTO) {
        self.castable = nil
        self.demoDTO = demoDTO
    }
}


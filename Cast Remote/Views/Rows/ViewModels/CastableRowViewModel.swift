//
//  CastableRowViewModel.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/14/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class CastableRowViewModel: ObservableObject, Identifiable {
    
    enum Size: Int {
        case large = 2
        case medium = 1
        case small = 0
        
        static func >= (lhs: Size, rhs: Size) -> Bool {
            return lhs.rawValue >= rhs.rawValue
        }
        
        static func <= (lhs: Size, rhs: Size) -> Bool {
            return lhs.rawValue <= rhs.rawValue
        }
    }
    
    enum Status {
        case connecting
        case casting
        case none
    }
    
    let id = UUID()
    
    @Published var selected: Bool = false
    @Published var status: Status = .none
    
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
    
    var thumbURL: URL? {
        if let stream = self.castable {
            return stream.channel?.thumbURL
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
    
    var size: Size { selected ? .large : (index < 3 ? .medium : .small) }
    var index: Int = 0
    
    var themeColor: Color {
        castable?.channel?.platform?.type.themeColor ?? .black
    }
    
    var icon: UIImage? {
        castable?.channel?.platform?.type.icon
    }
    
    let castable: TwitchStream?
    private let demoDTO: TwitchStreamDTO?
    
    init(castable: TwitchStream) {
        self.castable = castable
        self.demoDTO = nil
    }
    
    init(demoDTO: TwitchStreamDTO, index: Int, selected: Bool = false) {
        self.castable = nil
        self.demoDTO = demoDTO
        self.index = index
        self.selected = selected
    }
}


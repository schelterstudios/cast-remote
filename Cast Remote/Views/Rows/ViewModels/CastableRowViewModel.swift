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
        case failed
        case none
    }
    
    let id = UUID()
    
    @Published var selected: Bool = false
    @Published var status: Status = .none
    
    var title: String {
        if let castable = self.castable {
            return castable.title ?? ""
        } else if let dto = self.demoDTO {
            return "\(dto.channel.displayName) on \(dto.game)"
        }
        return ""
    }
    
    var subtitle: String? {
        if let castable = self.castable {
            return castable.subtitle
        } else if let dto = self.demoDTO {
            return dto.channel.status
        }
        return nil
    }
    
    var thumbURL: URL? {
        if let stream = self.castable {
            return stream.thumbURL
        } else if let raw = demoDTO?.preview.mediumRAW {
            return URL(string: raw)
        }
        return nil
    }
    
    var providerThumbURL: URL? {
        if let castable = self.castable {
            return castable.provider?.thumbURL
        }
        return nil
    }
    
    var viewCount: Int {
        if let castable = self.castable {
            return Int(castable.viewCount)
        } else {
            return demoDTO?.viewCount ?? 0
        }
    }
    
    var size: Size { selected ? .large : (index < 3 ? .medium : .small) }
    var index: Int = 0
    
    var themeColor: Color {
        castable?.provider?.platform?.type.themeColor ?? .black
    }
    
    var icon: UIImage? {
        castable?.provider?.platform?.type.icon
    }
    
    let castable: Castable?
    private let demoDTO: TwitchStreamDTO?
    
    init(castable: Castable) {
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


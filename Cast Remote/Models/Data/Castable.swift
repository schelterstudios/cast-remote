//
//  Castable.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 7/29/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation

protocol Castable {
    var path: String { get }
    var name: String { get }
    var thumbURL: URL? { get }
}

extension Castable where Self:Equatable {
    static func == (lhs: Castable, rhs: Castable) -> Bool {
        return lhs.path == rhs.path
    }
}

struct TwitchStream: Castable, Codable {
    
    var path: String { "https://www.twitch.tv/"+username }
    var name: String { username }// + " playing " + game }
    var thumbURL: URL? { URL(string: thumbURLRaw) }
    
    var id: String
    var thumbURLRaw: String
    var username: String
    //var game: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case thumbURLRaw = "thumbnail_url"
        case username = "user_name"
        //case game
    }
}

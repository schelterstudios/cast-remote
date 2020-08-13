//
//  DemoJSONLoader.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/11/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation

protocol DemoJSONLoader {}

extension DemoJSONLoader {
    
    func load<T: Decodable>(_ filename: String) -> T {
        let data: Data
        
        guard let file = Bundle.main.url(forResource: filename, withExtension: ".json")
            else {
                fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
}

class DemoJSON: DemoJSONLoader {
    var twitchChannels: [TwitchChannelDTO] {
        load("twitch_channels")
    }
}

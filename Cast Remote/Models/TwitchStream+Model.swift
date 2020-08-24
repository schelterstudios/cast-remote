//
//  TwitchStream+Model.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/14/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import CoreData

typealias TwitchStreamID = String

struct TwitchStreamDTO: Decodable {
    let id: QuantumValueDTO
    let channel: TwitchChannelDTO
    let preview: TwitchStreamPreview
    let game: String
    let viewCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case channel
        case preview
        case game
        case viewCount = "viewers"
    }
}

struct TwitchStreamPreview: Decodable {
    let smallRAW: String
    let mediumRAW: String
    let largeRAW: String
    
    enum CodingKeys: String, CodingKey {
        case smallRAW = "small"
        case mediumRAW = "medium"
        case largeRAW = "large"
    }
}

extension TwitchStream {
    
    static func model(dto: TwitchStreamDTO) -> TwitchStream {
        var model = TwitchStream.model(streamID: dto.id.stringValue)
        
        if model == nil {
            let viewContext = AppDelegate.current.persistentContainer.viewContext
            model = TwitchStream(context: viewContext)
            model?.streamID = dto.id.stringValue
        }
        
        model?.update(dto: dto)
        return model!
    }
    
    static func model(streamID: TwitchStreamID) -> TwitchStream? {
        var model: TwitchStream?
        
        let viewContext = AppDelegate.current.persistentContainer.viewContext
        let req: NSFetchRequest<TwitchStream> = TwitchStream.fetchRequest()
        req.predicate = NSPredicate(format: "streamID = %@", streamID)
        
        do {
            model = try viewContext.fetch(req).first
        } catch let err {
            fatalError("Unresolved error \(err)")
        }
        
        return model
    }
    
    func update(dto: TwitchStreamDTO) {
        if self.streamID != dto.id.stringValue { return }
        self.provider = TwitchChannel.model(dto: dto.channel)
        self.thumbRAW = dto.preview.mediumRAW
        self.previewRAW = dto.preview.largeRAW
        self.viewCount = Int32(dto.viewCount)
        
        self.title = dto.channel.displayName + " on " + dto.game
        self.subtitle = dto.channel.status
    }
}

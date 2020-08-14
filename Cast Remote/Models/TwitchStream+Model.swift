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

struct TwitchStreamDTO: Codable {
    var id: TwitchStreamID
    var channel: TwitchChannelDTO
    var preview: TwitchStreamPreview
    var game: String
    var viewCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case channel
        case preview
        case game
        case viewCount = "viewers"
    }
}

struct TwitchStreamPreview: Codable {
    var smallRAW: String
    var mediumRAW: String
    
    enum CodingKeys: String, CodingKey {
        case smallRAW = "small"
        case mediumRAW = "medium"
    }
}

extension TwitchStream {
    
    static func model(dto: TwitchStreamDTO) -> TwitchStream {
        var model = TwitchStream.model(streamID: dto.id)
        
        if model == nil {
            let viewContext = AppDelegate.current.persistentContainer.viewContext
            model = TwitchStream(context: viewContext)
            model?.streamID = dto.id
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
    
    var previewURL: URL? { URL(string: previewRAW!) }
    
    
    func update(dto: TwitchStreamDTO) {
        if self.streamID != dto.id { return }
        self.channel = TwitchChannel.model(dto: dto.channel)
        self.previewRAW = dto.preview.mediumRAW
        self.game = dto.game
        self.viewCount = Int32(dto.viewCount)
    }
}

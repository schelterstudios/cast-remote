//
//  TwitchChannel+Model.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/12/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import CoreData

typealias TwitchChannelID = String

struct TwitchChannelDTO: Codable {
    var id: TwitchChannelID
    var displayName: String
    var thumbRAW: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case displayName = "display_name"
        case thumbRAW = "logo"
    }
}

extension TwitchChannel {
    
    static func model(dto: TwitchChannelDTO) -> TwitchChannel {
        var model = TwitchChannel.model(channelID: dto.id)
        
        if model == nil {
            let viewContext = AppDelegate.current.persistentContainer.viewContext
            model = TwitchChannel(context: viewContext)
            model?.channelID = dto.id
            model?.platform = Platform.model(type: .twitch)
        }
        
        model?.update(dto: dto)
        return model!
    }
    
    static func model(channelID: TwitchChannelID) -> TwitchChannel? {
        var model: TwitchChannel?
        
        let viewContext = AppDelegate.current.persistentContainer.viewContext
        let req: NSFetchRequest<TwitchChannel> = TwitchChannel.fetchRequest()
        req.predicate = NSPredicate(format: "channelID = %@", channelID)
        
        do {
            model = try viewContext.fetch(req).first
        } catch let err {
            fatalError("Unresolved error \(err)")
        }
        
        return model
    }
    
    func update(dto: TwitchChannelDTO) {
        if self.channelID != dto.id { return }
        self.displayName = dto.displayName
        self.thumbRAW = dto.thumbRAW
    }
}

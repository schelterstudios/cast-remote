//
//  TwitchChannel+Model.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/12/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import CoreData

typealias TwitchChannelID = String

enum QuantumValueDTO: Decodable {
    case int(Int)
    case string(String)
    
    var stringValue: String {
        switch self {
        case .string(let value) : return value
        case .int(let value) : return "\(value)"
        }
    }
    
    init(from decoder: Decoder) throws {
        if let int = try? decoder.singleValueContainer().decode(Int.self) {
            self = .int(int)
            return
        }

        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }

        throw DecodeError.unexpectedType
    }

    enum DecodeError: Error {
        case unexpectedType
    }
}

struct TwitchChannelDTO: Decodable {
    let id: QuantumValueDTO
    let displayName: String
    let thumbRAW: String
    let urlRAW: String
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case displayName = "display_name"
        case thumbRAW = "logo"
        case urlRAW = "url"
        case status
    }
}

extension TwitchChannel {
    
    static func model(dto: TwitchChannelDTO) -> TwitchChannel {
        var model = TwitchChannel.model(channelID: dto.id.stringValue)
        
        if model == nil {
            let viewContext = AppDelegate.current.persistentContainer.viewContext
            model = TwitchChannel(context: viewContext)
            model?.channelID = dto.id.stringValue
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
        if self.channelID != dto.id.stringValue { return }
        self.displayName = dto.displayName
        self.thumbRAW = dto.thumbRAW
        self.urlRAW = dto.urlRAW
        self.status = dto.status
    }
}

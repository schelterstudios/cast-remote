//
//  Platform+Model.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/12/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import CoreData

struct User {
    let id: String
    let displayName: String
    let platformType: PlatformType
}

extension Platform {
    
    static func model(type: PlatformType) -> Platform {
        var model: Platform?
        
        let viewContext = AppDelegate.current.persistentContainer.viewContext
        let req: NSFetchRequest<Platform> = Platform.fetchRequest()
        req.predicate = NSPredicate(format: "typeRAW = %@", type.rawValue)
        
        do {
            model = try viewContext.fetch(req).first
        } catch let err {
            fatalError("Unresolved error \(err)")
        }
        
        if model == nil {
            model = Platform(context: viewContext)
            model?.type = type
        }
        
        return model!
    }
    
    var type: PlatformType {
        set { typeRAW = newValue.rawValue }
        get { PlatformType(rawValue: typeRAW!)! }
    }
    
    var user: User? {
        set {
            userID = newValue?.id
            username = newValue?.displayName
        }
        get {
            guard let uid = userID, let name = username else {
                return nil
            }
            return User(id: uid, displayName: name, platformType: type)
        }
    }
}

// MARK: - Twitch Platform

struct TwitchUserDTO: Decodable {
    let id: String
    let displayName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
    }
}

extension Platform {
    
    func createUser(dto: TwitchUserDTO) -> User {
        userID = dto.id
        username = dto.displayName
        return User(id: dto.id, displayName: dto.displayName, platformType: type)
    }
}

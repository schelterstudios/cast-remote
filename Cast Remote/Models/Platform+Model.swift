//
//  Platform+Model.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/12/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import CoreData

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
            switch type {
            case .twitch : model = TwitchPlatform(context: viewContext)
            //default : model = Platform(context: viewContext)
            }
            model?.type = type
        }
        
        return model!
    }
    
    var type: PlatformType {
        set { typeRAW = newValue.rawValue }
        get { PlatformType(rawValue: typeRAW!)! }
    }
}

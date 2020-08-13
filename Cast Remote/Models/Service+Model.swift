//
//  Service+Model.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/12/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import CoreData

extension Service {
    
    enum ServiceType: String {
        case twitch = "twitch"
    }
    
    static func model(type: ServiceType) -> Service {
        var model: Service?
        
        let viewContext = AppDelegate.current.persistentContainer.viewContext
        let req: NSFetchRequest<Service> = Service.fetchRequest()
        req.predicate = NSPredicate(format: "typeRAW = %@", type.rawValue)
        
        do {
            model = try viewContext.fetch(req).first
        } catch let err {
            fatalError("Unresolved error \(err)")
        }
        
        if model == nil {
            model = Service(context: viewContext)
            model?.type = type
        }
        
        return model!
    }
    
    var type: ServiceType {
        set { typeRAW = newValue.rawValue }
        get { ServiceType(rawValue: typeRAW)! }
    }
}

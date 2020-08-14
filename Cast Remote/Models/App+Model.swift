//
//  App+Model.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/12/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import CoreData

extension App {
    
    static private var _shared: App?
    
    static var shared: App {
        get {
            if (_shared == nil) {
                let viewContext = AppDelegate.current.persistentContainer.viewContext
                let req: NSFetchRequest<App> = App.fetchRequest()
                
                do {
                    _shared = try viewContext.fetch(req).first
                } catch let err {
                    fatalError("Unresolved error \(err)")
                }
                
                if (_shared == nil) {
                    _shared = App(context: viewContext)
                    _shared!.pinned = ProviderGroup(context: viewContext)
                }
            }
            return _shared!
        }
    }
}

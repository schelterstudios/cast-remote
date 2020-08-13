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
    
    static private var _current: App?
    
    static var current: App {
        get {
            if (_current == nil) {
                let viewContext = AppDelegate.current.persistentContainer.viewContext
                let req: NSFetchRequest<App> = App.fetchRequest()
                
                do {
                    _current = try viewContext.fetch(req).first
                } catch let err {
                    fatalError("Unresolved error \(err)")
                }
                
                if (_current == nil) {
                    _current = App(context: viewContext)
                    _current!.pinned = ProviderGroup(context: viewContext)
                }
            }
            return _current!
        }
    }
}

//
//  ProviderGroup+Model.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/14/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import CoreData

extension ProviderGroup {
    
    static private var _pinned: ProviderGroup?
    
    static var pinned: ProviderGroup {
        get {
            if (_pinned == nil) {
                let viewContext = AppDelegate.current.persistentContainer.viewContext
                let req: NSFetchRequest<ProviderGroup> = ProviderGroup.fetchRequest()
                
                do {
                    _pinned = try viewContext.fetch(req).first
                } catch let err {
                    fatalError("Unresolved error \(err)")
                }
                
                if (_pinned == nil) {
                    _pinned = ProviderGroup(context: viewContext)
                }
            }
            return _pinned!
        }
    }
    
    var allProviders: [Provider] {
        guard let providers = self.providers else { return [] }
        return providers.compactMap{ $0 as? Provider }
    }
    
    func providers(from type: PlatformType) -> [Provider] {
        return allProviders.filter{ $0.platform?.type == type }
    }
    
    func moveProviders(fromOffsets: IndexSet, toOffset: Int) {
        guard var arr = providers?.array else { return }
        arr.move(fromOffsets: fromOffsets, toOffset: toOffset)
        self.providers = NSOrderedSet(array: arr)
    }
}

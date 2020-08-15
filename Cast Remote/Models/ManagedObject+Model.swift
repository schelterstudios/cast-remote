//
//  ManagedObject+Model.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/14/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    func delete() {
        self.managedObjectContext?.delete(self)
    }
}

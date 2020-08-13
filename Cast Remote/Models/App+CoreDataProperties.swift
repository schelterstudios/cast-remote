//
//  App+CoreDataProperties.swift
//  
//
//  Created by Steve Schelter on 8/12/20.
//
//

import Foundation
import CoreData


extension App {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<App> {
        return NSFetchRequest<App>(entityName: "App")
    }

    @NSManaged public var pinned: ProviderGroup?

}

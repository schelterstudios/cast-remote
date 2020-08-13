//
//  Service+CoreDataProperties.swift
//  
//
//  Created by Steve Schelter on 8/12/20.
//
//

import Foundation
import CoreData


extension Service {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Service> {
        return NSFetchRequest<Service>(entityName: "Service")
    }

    @NSManaged public var typeRAW: String!
    @NSManaged public var providers: NSSet?

}

// MARK: Generated accessors for providers
extension Service {

    @objc(addProvidersObject:)
    @NSManaged public func addToProviders(_ value: Provider)

    @objc(removeProvidersObject:)
    @NSManaged public func removeFromProviders(_ value: Provider)

    @objc(addProviders:)
    @NSManaged public func addToProviders(_ values: NSSet)

    @objc(removeProviders:)
    @NSManaged public func removeFromProviders(_ values: NSSet)

}

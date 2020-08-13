//
//  ProviderGroup+CoreDataProperties.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/12/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import CoreData


extension ProviderGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProviderGroup> {
        return NSFetchRequest<ProviderGroup>(entityName: "ProviderGroup")
    }

    @NSManaged public var providers: NSOrderedSet?
    @NSManaged public var app: App?

}

// MARK: Generated accessors for providers
extension ProviderGroup {

    @objc(insertObject:inProvidersAtIndex:)
    @NSManaged public func insertIntoProviders(_ value: Provider, at idx: Int)

    @objc(removeObjectFromProvidersAtIndex:)
    @NSManaged public func removeFromProviders(at idx: Int)

    @objc(insertProviders:atIndexes:)
    @NSManaged public func insertIntoProviders(_ values: [Provider], at indexes: NSIndexSet)

    @objc(removeProvidersAtIndexes:)
    @NSManaged public func removeFromProviders(at indexes: NSIndexSet)

    @objc(replaceObjectInProvidersAtIndex:withObject:)
    @NSManaged public func replaceProviders(at idx: Int, with value: Provider)

    @objc(replaceProvidersAtIndexes:withProviders:)
    @NSManaged public func replaceProviders(at indexes: NSIndexSet, with values: [Provider])

    @objc(addProvidersObject:)
    @NSManaged public func addToProviders(_ value: Provider)

    @objc(removeProvidersObject:)
    @NSManaged public func removeFromProviders(_ value: Provider)

    @objc(addProviders:)
    @NSManaged public func addToProviders(_ values: NSOrderedSet)

    @objc(removeProviders:)
    @NSManaged public func removeFromProviders(_ values: NSOrderedSet)

}

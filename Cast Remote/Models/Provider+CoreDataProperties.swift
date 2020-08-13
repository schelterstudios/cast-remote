//
//  Provider+CoreDataProperties.swift
//  
//
//  Created by Steve Schelter on 8/12/20.
//
//

import Foundation
import CoreData


extension Provider {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Provider> {
        return NSFetchRequest<Provider>(entityName: "Provider")
    }

    @NSManaged public var displayName: String!
    @NSManaged public var thumbRAW: String!
    @NSManaged public var service: Service?
    @NSManaged public var groups: NSSet?

}

// MARK: Generated accessors for groups
extension Provider {

    @objc(addGroupsObject:)
    @NSManaged public func addToGroups(_ value: ProviderGroup)

    @objc(removeGroupsObject:)
    @NSManaged public func removeFromGroups(_ value: ProviderGroup)

    @objc(addGroups:)
    @NSManaged public func addToGroups(_ values: NSSet)

    @objc(removeGroups:)
    @NSManaged public func removeFromGroups(_ values: NSSet)

}

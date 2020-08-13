//
//  TwitchChannel+CoreDataProperties.swift
//  
//
//  Created by Steve Schelter on 8/12/20.
//
//

import Foundation
import CoreData


extension TwitchChannel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TwitchChannel> {
        return NSFetchRequest<TwitchChannel>(entityName: "TwitchChannel")
    }

    @NSManaged public var channelID: String!

}

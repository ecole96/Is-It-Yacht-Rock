//
//  DBEntry+CoreDataProperties.swift
//  IsItYacht
//
//  Created by Evan Cole on 9/17/18.
//  Copyright © 2018 Evan Cole. All rights reserved.
//
//

import Foundation
import CoreData

// property file for database entry
extension DBEntry {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBEntry> {
        return NSFetchRequest<DBEntry>(entityName: "DBEntry")
    }

    @NSManaged public var artist: String
    @NSManaged public var dave: Float
    @NSManaged public var hunter: Float
    @NSManaged public var imageURL: String?
    @NSManaged public var jd: Float
    @NSManaged public var show: String
    @NSManaged public var simplifiedTitle: String
    @NSManaged public var steve: Float
    @NSManaged public var title: String
    @NSManaged public var yachtski: Float
    
    // computed property - determine yachtski label based on score
    @objc var yachtOrNyacht: String {
        var yon: String
        if yachtski >= 50 {
            yon = "YACHT"
        }
        else {
            yon = "NYACHT"
        }
        return yon
    }
}

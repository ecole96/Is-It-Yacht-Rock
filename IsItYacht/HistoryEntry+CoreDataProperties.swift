//
//  HistoryEntry+CoreDataProperties.swift
//  IsItYacht
//
//  Created by Evan Cole on 9/10/18.
//  Copyright © 2018 Evan Cole. All rights reserved.
//
//

import Foundation
import CoreData

// property file for history entries (very similar to DBEntry, but for user's recorded matches)
extension HistoryEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoryEntry> {
        return NSFetchRequest<HistoryEntry>(entityName: "HistoryEntry")
    }

    @NSManaged public var artist: String
    @NSManaged public var date: Date
    @NSManaged public var title: String
    @NSManaged public var yachtski: NSNumber?
    @NSManaged public var steve: NSNumber?
    @NSManaged public var dave: NSNumber?
    @NSManaged public var jd: NSNumber?
    @NSManaged public var hunter: NSNumber?
    @NSManaged public var show: String?
    @NSManaged public var imageURL: String?
    
    // keep track of recording date in History (for section headers) - in "Month Day, Year" format
    @objc var date_header: String {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .none
        return df.string(from: date)
    }
    
    // yachtki label computed property
    @objc var yachtOrNyacht: String {
        var yon = "Unknown"
        if yachtski != nil {
            if yachtski!.floatValue >= 50 {
                yon = "YACHT"
            }
            else {
                yon = "NYACHT"
            }
        }
        return yon
    }
        
}

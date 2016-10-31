//
//  PlaylistObject+CoreDataProperties.swift
//  
//
//  Created by Andrii Tiischenko on 10/31/16.
//
//

import Foundation
import CoreData


extension PlaylistObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaylistObject> {
        return NSFetchRequest<PlaylistObject>(entityName: "PlaylistObject");
    }

    @NSManaged public var date_added: NSDate?
    @NSManaged public var is_sync: Bool
    @NSManaged public var item_id: Double
    @NSManaged public var title: String?
    @NSManaged public var files: NSSet?

}

// MARK: Generated accessors for files
extension PlaylistObject {

    @objc(addFilesObject:)
    @NSManaged public func addToFiles(_ value: FileObject)

    @objc(removeFilesObject:)
    @NSManaged public func removeFromFiles(_ value: FileObject)

    @objc(addFiles:)
    @NSManaged public func addToFiles(_ values: NSSet)

    @objc(removeFiles:)
    @NSManaged public func removeFromFiles(_ values: NSSet)

}

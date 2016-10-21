//
//  ActivePlaylistObject+CoreDataProperties.swift
//  
//
//  Created by Andrii Tiischenko on 10/21/16.
//
//

import Foundation
import CoreData
 

extension ActivePlaylistObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActivePlaylistObject> {
        return NSFetchRequest<ActivePlaylistObject>(entityName: "ActivePlaylistObject");
    }

    @NSManaged public var item_id: Double
    @NSManaged public var fileobject: FileObject?

}

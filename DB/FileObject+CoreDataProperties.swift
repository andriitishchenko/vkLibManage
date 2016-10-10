//
//  FileObject+CoreDataProperties.swift
//  
//
//  Created by Andrii Tiischenko on 10/10/16.
//
//

import Foundation
import CoreData

enum FileObjectStatus:Int {
    case None
    case Started
    case Done
}
 

extension FileObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FileObject> {
        return NSFetchRequest<FileObject>(entityName: "FileObject");
    }

    @NSManaged public var artist: String?
    @NSManaged public var duration: Double
    @NSManaged public var filepath: String?
    @NSManaged public var item_id: Double
    @NSManaged public var playlist_id: Double
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var playlist: PlaylistObject?
    
    /*
        0 - none
        1 - download started
        2 - download Done
     
     */
    @NSManaged public var status: Int

}

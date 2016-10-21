//
//  FileObject+CoreDataProperties.swift
//  
//
//  Created by Andrii Tiischenko on 10/21/16.
//
//

import Foundation
import CoreData

extension FileObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FileObject> {
        return NSFetchRequest<FileObject>(entityName: "FileObject");
    }

    @NSManaged public var artist: String?
    @NSManaged public var duration: Double
    @NSManaged public var item_id: Double
    @NSManaged public var playlist_id: Double
    @NSManaged public var status: Int
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var playcount: Double
    @NSManaged public var playlist: PlaylistObject?
    @NSManaged public var activePlaylist: ActivePlaylistObject?

}

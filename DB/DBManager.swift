//
//  DBManager.swift
//  vkLibManage
//
//  Created by Andrii Tiischenko on 10/10/16.
//  Copyright © 2016 Andrii Tiischenko. All rights reserved.
//

import UIKit
import CoreData

class DBManager: NSObject {
    private override init() { }
    static let sharedInstance: DBManager = DBManager()
 
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "vkLibManage")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    
    //-----------------------------------------------
    func getFileDownloadQueue() {
        let context = persistentContainer.viewContext
        context.performAndWait({
            let request : NSFetchRequest<FileObject> = FileObject.fetchRequest()
            request.predicate = NSPredicate(format: "status == %d", FileObjectStatus.None.rawValue)
            
            do {
                let searchResults = try request.execute()
                
            } catch {
                print("Error with request: \(error)")
            }
        })
    }

    //-----------------------------------------------
    func getLocalPlaylists(rez:@escaping (Array<PlaylistItem>)->Void) {
        let context = persistentContainer.viewContext
        context.performAndWait({
            let request : NSFetchRequest<PlaylistObject> = PlaylistObject.fetchRequest()
            do {
                var rezOut:Array<PlaylistItem> = []
                let searchResults = try request.execute()
                for item in searchResults{
                    let el:PlaylistItem = PlaylistItem(item)
                    rezOut.append(el)
                }
                rez(rezOut)
                
            } catch {
                print("Error with request: \(error)")
            }
        })
    }
    
    //-----------------------------------------------
    func getLocalTracks(playlist_id:Int, rez:@escaping (Array<TrackItem>)->Void) {
        let context = persistentContainer.viewContext
        context.performAndWait({
            let request : NSFetchRequest<FileObject> = FileObject.fetchRequest()
            request.predicate = NSPredicate(format: "playlist_id == %d", playlist_id)
            do {
                var rezOut:Array<TrackItem> = []
                let searchResults = try request.execute()
                for item in searchResults{
                    let el:TrackItem = TrackItem(item)
                    rezOut.append(el)
                }
                rez(rezOut)
                
            } catch {
                print("Error with request: \(error)")
            }
        })
    }
    
    
    //-----------------------------------------------
    func updateLocalPlaylist(_ item:PlaylistItem)->PlaylistObject
    {
        var rez:PlaylistObject? = nil
        let context = persistentContainer.viewContext
        context.performAndWait({
            let request : NSFetchRequest<PlaylistObject> = PlaylistObject.fetchRequest()
            request.predicate = NSPredicate(format: "item_id == %d", item.id)
            do {
                let searchResults = try request.execute()
                if (searchResults.count > 0){
                    rez = searchResults.first
                }
                else
                {
                    rez =  NSEntityDescription.insertNewObject(forEntityName: "PlaylistObject", into: context) as? PlaylistObject
                    rez?.is_sync = false
                    rez?.item_id = Double(item.id)
                    rez?.title = item.title
                    try context.save()
                }
                
            } catch {
                print("Error with request: \(error)")
            }
        })
        return rez!
    }
    
    
    
    //-----------------------------------------------
    func updateLocalTrack(_ item:TrackItem)->FileObject
    {
        var rez:FileObject? = nil
        let context = persistentContainer.viewContext
        context.performAndWait({
            let request : NSFetchRequest<FileObject> = FileObject.fetchRequest()
            request.predicate = NSPredicate(format: "item_id == %d", item.id)
            do {
                let searchResults = try request.execute()
                if (searchResults.count > 0){
                    rez = searchResults.first
                }
                else
                {
                    rez = NSEntityDescription.insertNewObject(forEntityName: "FileObject", into: context) as? FileObject
                    rez?.item_id = Double(item.id)
                    rez?.title = item.title
                    rez?.artist = item.artist
                    rez?.duration = Double(item.duration)
                    rez?.playlist_id = Double(item.album_id)
                    rez?.url = item.url
                    rez?.status = FileObjectStatus.None.rawValue
                    //rez?.playlist =

                    try context.save()
                }
                
            } catch {
                print("Error with request: \(error)")
            }
        })
        return rez!
    }
    
    
    
}
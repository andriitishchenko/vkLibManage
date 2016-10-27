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
            print(storeDescription)
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
            do {
                
                let request : NSFetchRequest<FileObject> = FileObject.fetchRequest()
                request.predicate = NSPredicate(format: "item_id == %d", item.id)
                
                let requestPL : NSFetchRequest<PlaylistObject> = PlaylistObject.fetchRequest()
                requestPL.predicate = NSPredicate(format: "item_id == %d", item.album_id)
                let searchResultsPL = try requestPL.execute()
                let pl:PlaylistObject? = searchResultsPL.first
                
                let searchResults = try request.execute()
                if (searchResults.count > 0){
                    rez = searchResults.first
                    rez?.url = item.url
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
                    rez?.playlist = pl
                }
                try context.save()

                
            } catch {
                print("Error with request: \(error)")
            }
        })
        return rez!
    }
    
    func updateTrackStatus(_ trackId:Int, status:FileObjectStatus){
        let context = persistentContainer.viewContext
        context.performAndWait({
            let request : NSFetchRequest<FileObject> = FileObject.fetchRequest()
            request.predicate = NSPredicate(format: "item_id == %d", trackId)
            do {
                let searchResults = try request.execute()
                if (searchResults.count > 0){
                    let file:FileObject = searchResults.first!
                    file.status = status.rawValue
                    try context.save()
                }
                
            } catch {
                print("Error with request: \(error)")
            }
        })

    }
    
    func removePlaylistItems(_ items:[TrackItem])
    {
        
    }
    
    
    
//    PLAYLIST
    func addPlaylistItems(_ items:[TrackItem], finish:@escaping ()->Void){
        let context = persistentContainer.viewContext
        
            context.perform({ () -> Void in
                do {
                    for item in items
                    {
                        let request : NSFetchRequest<FileObject> = FileObject.fetchRequest()
                        request.predicate = NSPredicate(format: "item_id == %d", item.id)
                    
                            let searchResults = try request.execute()
                            if (searchResults.count > 0){
                                let file:FileObject = searchResults.first!
                                var apl = NSEntityDescription.insertNewObject(forEntityName: "ActivePlaylistObject", into: context) as? ActivePlaylistObject
                                apl?.item_id = Double(item.id)
                                apl?.fileobject = file
                                try context.save()
                            }
                    }
                    try context.save()
                } catch {
                    print("Error with request: \(error)")
                }
                finish()
            });
    
    }
    
    func replacePlaylistItemsWith(_ items:[TrackItem]){
        let context = persistentContainer.viewContext
        let request : NSFetchRequest<ActivePlaylistObject> = ActivePlaylistObject.fetchRequest()
        request.returnsObjectsAsFaults = false
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch let error as NSError {
            debugPrint(error)
        }
        
        self.addPlaylistItems(items,finish: {})
    }
    
    
    func addPlaylistWithID(_ itemID:Int) {
        self.getLocalTracks(playlist_id: itemID) { list in
            DBManager.sharedInstance.addPlaylistItems(list, finish: {})
        }
    }
    
    func replacePlaylistWithID(_ itemID:Int) {
        self.getLocalTracks(playlist_id: itemID) { list in
            DBManager.sharedInstance.replacePlaylistItemsWith(list)
        }
    }
    
    func getActivePlaylist() -> [TrackItem]{
        let context = persistentContainer.viewContext
        let request : NSFetchRequest<ActivePlaylistObject> = ActivePlaylistObject.fetchRequest()
        var rezOut:Array<TrackItem> = []
        do {
            let searchResults = try request.execute()
            for item:ActivePlaylistObject in searchResults{
                let el:TrackItem = TrackItem(item.fileobject!)
                rezOut.append(el)
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return rezOut
    }
    
    func getNextPlaylistItem () -> TrackItem? {
        let context = persistentContainer.viewContext
        let request : NSFetchRequest<ActivePlaylistObject> = ActivePlaylistObject.fetchRequest()
        request.fetchLimit = 1
        //request.sortDescriptors = NSSortDescriptor(key: "name", ascending: true)
        //request.predicate = NSPredicate(format: "SELF.fileobject.playcount == fileobject.@min.playcount")
        
        
        
        //http://www.cimgf.com/2015/06/25/core-data-and-aggregate-fetches-in-swift/
        
        let kexp = NSExpression(forKeyPath: "fileobject.playcount")
        let minExp = NSExpression(forFunction: "min:", arguments: [kexp])
        let expr = NSExpressionDescription()
        expr.name = "minPlay"
        expr.expression = minExp
        expr.expressionResultType = .doubleAttributeType
        var expAny = [AnyObject]()
        expAny.append(expr)
        request.propertiesToFetch = expAny

        
        var rez:TrackItem? = nil
        do {
            let searchResults = try request.execute()
            if let item = searchResults.first {
                rez = TrackItem(item.fileobject!)
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return rez
    }
    
    
}

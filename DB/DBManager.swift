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
    
    func updateTrackStatus(_ trackId:Double, status:FileObjectStatus){
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
    
    
//    func getFileObjectInContext(_ item_id:Double, context:NSManagedObjectContext, result:@escaping (FileObject?) -> Void ) {
//        context.perform({ () -> Void in
//            var rez:FileObject? = nil
//            do {
//                let request : NSFetchRequest<FileObject> = FileObject.fetchRequest()
//                request.predicate = NSPredicate(format: "item_id == %d", item_id)
//                request.fetchLimit = 1
//                let searchResults = try request.execute()
//                rez = searchResults.first
//            } catch {
//                print("Error with request: \(error)")
//            }
//            result(rez)
//        });
//    }
  
    
//    PLAYLIST
    func addPlaylistItems(_ items:[TrackItem], finish:@escaping ()->Void){
        let context = persistentContainer.viewContext
            context.perform({ () -> Void in
                do {
                    for item in items
                    {
                      let request : NSFetchRequest<FileObject> = FileObject.fetchRequest()
                          request.predicate = NSPredicate(format: "item_id == %@", item.id as NSNumber)
                          request.fetchLimit = 1
                          let searchResults = try request.execute()
                          if let fo:FileObject = searchResults.first {
                            fo.is_in_queue = true
                          }
                    }
                    try context.save()
                } catch {
                    print("Error with request: \(error)")
                }
              
              
                finish()
            });
    }
    
//   CLEAR QUEUE PLAYLIST 
    func clearPlaylistQueue(context:NSManagedObjectContext?, finish:@escaping ()->Void) {
        let moc:NSManagedObjectContext = (context != nil) ? context! : persistentContainer.viewContext
        let updateRequest = NSBatchUpdateRequest(entityName: NSStringFromClass(FileObject.self))
        updateRequest.predicate = NSPredicate(format: "is_in_queue == %@", true as NSNumber)
        updateRequest.propertiesToUpdate = ["is_in_queue": (false as NSNumber) ]
        updateRequest.resultType = .updatedObjectsCountResultType
      
        do {
          try moc.execute(updateRequest)
        } catch let error as NSError {
          let fetchError = error as NSError
          print(fetchError)
        }
        finish()
    }
  
  
    
    func replacePlaylistItemsWith(_ items:[TrackItem]){
      let context = persistentContainer.viewContext
      self.clearPlaylistQueue(context: context) {
        try? context.save()
        self.addPlaylistItems(items){
          print("updated")
        }
      }
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
    
  func getActivePlaylist(rez:@escaping (Array<TrackItem>)->Void){
        let context = persistentContainer.viewContext
        let request : NSFetchRequest<FileObject> = FileObject.fetchRequest()
        request.predicate = NSPredicate(format: "is_in_queue == %@", true as NSNumber)
        var rezOut:Array<TrackItem> = []
        do {
            let searchResults = try context.fetch(request)
            for item in searchResults{
                let el:TrackItem = TrackItem(item)
                rezOut.append(el)
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        rez(rezOut)
    }
    
    func getNextPlaylistItem () -> TrackItem? {
        let context = persistentContainer.viewContext
        let request : NSFetchRequest<FileObject> = FileObject.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "is_in_queue == %@", true as NSNumber)
        request.sortDescriptors = [NSSortDescriptor(key: "playcount", ascending: true)]

        var rez:TrackItem? = nil
        do {
          
            let searchResults = try context.fetch(request)
            if let item = searchResults.first {
                item.playcount = item.playcount + 1
                try context.save()
                rez = TrackItem(item)
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return rez
    }
  
//  func updateStatCount(context:NSManagedObjectContext?, finish:@escaping ()->Void){
//      let moc:NSManagedObjectContext = (context != nil) ? context! : persistentContainer.viewContext
//      moc.perform({ () -> Void in
//        do {
//          for item in items
//          {
//            let request : NSFetchRequest<FileObject> = FileObject.fetchRequest()
//            request.predicate = NSPredicate(format: "item_id == %@", item.id as NSNumber)
//            request.fetchLimit = 1
//            let searchResults = try request.execute()
//            if let fo:FileObject = searchResults.first {
//              fo.is_in_queue = true
//            }
//          }
//          try context.save()
//        } catch {
//          print("Error with request: \(error)")
//        }
//        finish()
//      });
//    
//  }
  
  
}

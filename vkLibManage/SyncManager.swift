//
//  SyncManager.swift
//  vkLibManage
//
//  Created by Andrii Tiischenko on 10/10/16.
//  Copyright © 2016 Andrii Tiischenko. All rights reserved.
//

import UIKit
import CoreData

class SyncManager: NSObject {
    private override init() { }
    static let sharedInstance: SyncManager = SyncManager()
    
    func syncFile(_ item:TrackItem){
        DBManager.sharedInstance.updateLocalTrack(item)
    }
    
    func syncPlaylist(_ item:PlaylistItem){
        DBManager.sharedInstance.updateLocalPlaylist(item)
    }
    
    func sync(finish:()->Void){
        API.sharedInstance.getUserAlbums(seccess: { list in
            for item in list! {
                self.syncPlaylist(item)
                API.sharedInstance.getUserAudioInAlbum(albumId: item.id, seccess: { listfiles in
                    for item_file in listfiles! {
                        self.syncFile(item_file)
                    }
                    
                    }, fail: { (err) in
                        print("VK error: %@",err?.localizedDescription)
                })
            }
            },
             fail: { err in
                print("VK error: %@",err?.localizedDescription)
            }
        )
    }
    


    
//    func sync(){
//        
//        let request = NSFetchRequest(entityName:"Animal")
//        request.fetchBatchSize = 10
//        let results = try container.viewContext.executeFetchRequest(request)
//        let first = results.first
//        var aname = first.name // pull in the first batch's row data
//        
//        let moc = container.newBackgroundContext
//        
//        moc.performBlockAndWait() {
//            let update = NSBatchUpdateRequest(entityName:"Animal")
//            update.resultsType = .UpdatedObjectsCountResultType
//            update.propertiesToUpdate = ["name" : NSExpression(forConstantValue:"Cat")]
//            do {
//                let result = try moc.executeRequest(update)
//            } catch {
//                print("Error executing update: \(error)")
//            }
//        }
//        
//        
//    }
}

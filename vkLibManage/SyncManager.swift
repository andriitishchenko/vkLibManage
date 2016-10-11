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
    
    lazy var downloadManager: MZDownloadManager = {
        [unowned self] in
        let sessionIdentifer: String = "com.vkLibManage.SyncManager.BackgroundSession"
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var completion = appDelegate.backgroundSessionCompletionHandler
        
        let downloadmanager = MZDownloadManager(session: sessionIdentifer, delegate: self, completion: completion)
        return downloadmanager
        }()
    
    
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
    
    func downloadPlaylist(_ item:PlaylistItem) {
        DBManager.sharedInstance.getLocalTracks(playlist_id: item.id) { list in
            let dir = MZUtility.baseFilePath
            for track in list {
                self.downloadManager.addDownloadTask( String(track.id).appending(".mp3"), fileURL: track.url, destinationPath: dir, tag:track.id)
            }
        }
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



extension SyncManager: MZDownloadManagerDelegate {
    
    func downloadRequestStarted(_ downloadModel: MZDownloadModel, index: Int) {
        DBManager.sharedInstance.updateTrackStatus(downloadModel.tag, status: .Started)
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(_ downloadModels: [MZDownloadModel]) {
        
    }
    
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int) {
        
    }
    
    func downloadRequestDidPaused(_ downloadModel: MZDownloadModel, index: Int) {
        
    }
    
    func downloadRequestDidResumed(_ downloadModel: MZDownloadModel, index: Int) {
        
    }
    
    func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int) {
        DBManager.sharedInstance.updateTrackStatus(downloadModel.tag, status: .None)
    }
    
    func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int) {
        DBManager.sharedInstance.updateTrackStatus(downloadModel.tag, status: .Done)
        downloadManager.presentNotificationForDownload("Ok", notifBody: "Download did completed")
        let docDirectoryPath : NSString = (MZUtility.baseFilePath as NSString).appendingPathComponent(downloadModel.fileName) as NSString
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MZUtility.DownloadCompletedNotif as String), object: docDirectoryPath)
    }
    
    func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: MZDownloadModel, index: Int) {
        DBManager.sharedInstance.updateTrackStatus(downloadModel.tag, status: .None)
        debugPrint("Error while downloading file: \(downloadModel.fileName)  Error: \(error)")
    }
    
    //Oppotunity to handle destination does not exists error
    //This delegate will be called on the session queue so handle it appropriately
    func downloadRequestDestinationDoestNotExists(_ downloadModel: MZDownloadModel, index: Int, location: URL) {
        DBManager.sharedInstance.updateTrackStatus(downloadModel.tag, status: .Done)
        let myDownloadPath = MZUtility.baseFilePath + "/Default folder"
        if !FileManager.default.fileExists(atPath: myDownloadPath) {
            try! FileManager.default.createDirectory(atPath: myDownloadPath, withIntermediateDirectories: true, attributes: nil)
        }
        let fileName = MZUtility.getUniqueFileNameWithPath((myDownloadPath as NSString).appendingPathComponent(downloadModel.fileName as String) as NSString)
        let path =  myDownloadPath + "/" + (fileName as String)
        try! FileManager.default.moveItem(at: location, to: URL(fileURLWithPath: path))
        debugPrint("Default folder path: \(myDownloadPath)")
    }
}

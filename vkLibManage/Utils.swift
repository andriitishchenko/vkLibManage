//
//  Utils.swift
//  vkLibManage
//
//  Created by Andrii Tiischenko on 10/20/16.
//  Copyright © 2016 Andrii Tiischenko. All rights reserved.
//

import UIKit


enum AppNotifications: String{
    case DownloadProgress = "AppNotificationsDownloadProgress"
    case DownloadCompleted = "AppNotificationsDownloadCompleted"
}

extension Notification.Name {
    static let AppNotificationsDownloadProgress = Notification.Name("AppNotificationsDownloadProgress")
    static let AppNotificationsDownloadCompleted = Notification.Name("AppNotificationsDownloadCompleted")
    static let AppNotificationsSyncProgress = Notification.Name("AppNotificationsSyncProgress")
}


enum FileObjectStatus:Int {
    case None
    case Started
    case Done
}

class Utils: NSObject {

}

extension FileManager {
    static func isFileExistForID(_ id:Int) -> Bool{
        let filepath = FileManager.makeFilePathForID(id)
        let url : URL = URL(fileURLWithPath: filepath as String)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    static func makeFilePathForID(_ id:Int)->String{
        let fname = FileManager.makeFileNameForID(id);
        return MZUtility.baseFilePath.appending(fname)
    }
    
    static func makeFileNameForID(_ id:Int)->String{
        return String(id).appending(".mp3")
    }
}

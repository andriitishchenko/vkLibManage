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
    static func isFileExistForID(_ id:Double) -> Bool{
        let filepath = FileManager.makeFilePathForID(id)
        let url : URL = URL(fileURLWithPath: filepath as String)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    static func makeFilePathForID(_ id:Double)->String{
        let fname:String = FileManager.makeFileNameForID(id);
        return (MZUtility.baseFilePath as NSString).appendingPathComponent(fname)
    }
    
    static func makeFileNameForID(_ id:Double)->String{
        return String(format: "%.0f",id).appending(".mp3")
    }
}

//
//  PlaylistItem.swift
//  vkLibManage
//
//  Created by Andrii Tiischenko on 10/7/16.
//  Copyright © 2016 Andrii Tiischenko. All rights reserved.
//

import Foundation

struct ProgressType {
    var total:Int = 0
    var progress:Int = 0
    
    func toString() -> String {
        return String(self.progress)+" / "+String(self.total)
    }
    
    init(total:Int,progress:Int) {
        self.total = total
        self.progress = progress
    }
}

class TrackItem: NSObject {
    var id:Double = 0
    var album_id:Double = 0;
    var artist:String = "";
    var duration:Int = 0;
    var lyrics_id:Double = 0;
    var owner_id:Double = 0;
    var title:String = "";
    var url:String = "";
    var status:FileObjectStatus = .None;
    
    init(_ param:FileObject) {
        id = param.item_id
        title = param.title!
        artist = param.artist!
        album_id = param.playlist_id
        url = param.url!
        status = FileObjectStatus(rawValue: param.status)!
    }
    override init() {}
    
    func getFileURL() ->URL {
        let fpath = FileManager.makeFilePathForID(id)
        let url_mp3 : URL = URL(fileURLWithPath: fpath as String)
        if FileManager.default.fileExists(atPath: url_mp3.path) {
            return url_mp3
        }
        return URL(string:self.url)!
    }
}


class PlaylistItem : NSObject{
    var id:Int = 0
    var owner_id:Int = 0
    var title:String = ""
    
    init(_ param:PlaylistObject) {
        id = Int(param.item_id)
        title = param.title!
    }
    
    override init() {}
    
}

class Playlist : NSObject {
    var count:Int=0
    var items:Array<PlaylistItem>? = nil
    
    class func  modelContainerPropertyGenericClass() -> NSDictionary {
    return ["count" : Int.self,
            "items" : PlaylistItem.self];
    }
}

class TracksList : NSObject {
    var count:Int=0
    var items:Array<TrackItem>? = nil
    
    class func  modelContainerPropertyGenericClass() -> NSDictionary {
        return ["count" : Int.self,
                "items" : TrackItem.self];
    }
}


class PlaylistResponce: NSObject {
    var response:Playlist? = nil
}


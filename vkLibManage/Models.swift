//
//  PlaylistItem.swift
//  vkLibManage
//
//  Created by Andrii Tiischenko on 10/7/16.
//  Copyright © 2016 Andrii Tiischenko. All rights reserved.
//

import Foundation



class TrackItem: NSObject {
    var id:Int = 0
    var album_id:Int = 0;
    var artist:String = "";
    var duration:Int = 0;
    var lyrics_id:Int = 0;
    var owner_id:Int = 0;
    var title:String = "";
    var url:String = "";
    
    init(_ param:FileObject) {
        id = Int(param.item_id)
        title = param.title!
        artist = param.artist!
        album_id = Int(param.playlist_id)
        url = param.url!
    }
    override init() {}
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


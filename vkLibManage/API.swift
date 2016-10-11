//
//  API.swift
//  vkLibManage
//
//  Created by Andrii Tiischenko on 10/7/16.
//  Copyright © 2016 Andrii Tiischenko. All rights reserved.
//

import Foundation
typealias Dic = Dictionary<String,AnyObject>

class API{
    
    //private override init() { }
    static let sharedInstance: API = API()
    
    /*
        get user audio albums
     */
    func getUserAlbums(seccess:@escaping (Array<PlaylistItem>?)->Void, fail:@escaping (NSError?)->Void){
        let audioReq:VKRequest = VKRequest.init(method: "audio.getAlbums", parameters: [:])
        
        audioReq.execute(resultBlock: { (response) in
            print(response?.json)
            print(response?.parsedModel)
            let k = Playlist.yy_model(withJSON: (response?.json as! Dic))
            seccess(k?.items)
        }) { (err) in
            print("VK error: %@",err?.localizedDescription)
            if ((err as! NSError).code != Int(VK_API_ERROR)) {
                (err as! VKError).request.repeat()
            } else {
                fail(err as NSError?)
            }
        }
    }
    
    /*
        get audio tracks in album
     */
    func getUserAudioInAlbum(albumId:Int, seccess:@escaping (Array<TrackItem>?)->Void, fail:@escaping (NSError?)->Void){
        if albumId == 0 {
            fail(nil)
        }
        let audioReq:VKRequest = VKRequest.init(method: "audio.get", parameters: ["album_id":albumId])
        audioReq.execute(resultBlock: { (response) in
            print(response?.json)
            let k = TracksList.yy_model(withJSON: (response?.json as! Dic))
            seccess(k?.items)
        }) { (err) in
            print("VK error: %@",err?.localizedDescription)
            if ((err as! NSError).code != Int(VK_API_ERROR)) {
                (err as! VKError).request.repeat()
            } else {
                fail(err as NSError?)
            }
        }
    }
    
}

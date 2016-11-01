//
//  Player.swift
//  vkLibManage
//
//  Created by Andrii Tiischenko on 10/19/16.
//  Copyright © 2016 Andrii Tiischenko. All rights reserved.
//

import UIKit
import MediaPlayer

//@objc(Player)
class Player: NSObject, PrivatPlayerDelegate {

    
    private var privatePlayer = PrivatPlayer()
    
    static let sharedInstance: Player = Player()
    
    //private override
    private override init() {
        super.init()
        self.privatePlayer.delegate = self
    }
    
//    deinit {
//       
//    }

    
    func addToQueue(_ item:TrackItem){
//        self.jukebox.append(item: JukeboxItem (URL: URL(string: "http://www.noiseaddicts.com/samples_1w72b820/2228.mp3")!), loadingAssets: false)
    }

    func privatPlayerGetNextTrack() -> PrivatPlayerMediaItem? {
        
        if let item = DBManager.sharedInstance.getNextPlaylistItem() {
            var media = PrivatPlayerMediaItem()
            media.url =  item.getFileURL()
            media.title = item.title
            media.artist = item.artist
            return media
        }
        return nil
    }
    
    func privatPlayerGetPrevTrack() -> PrivatPlayerMediaItem?{
        if let item = DBManager.sharedInstance.getNextPlaylistItem() {
            var media = PrivatPlayerMediaItem()
            media.url =  item.getFileURL()
            media.title = item.title
            media.artist = item.artist
            return media
        }
        return nil
    }
    
    func privatPlayerDidStartedTrack(){
    
    }
    
    func privatPlayerDidFinishedTrack(){
    
    }
    

    
    
    
///     PLAYLIST CONTROL
  
    func play(){
      self.privatePlayer.play()
    }
    
    func stop(){
        //self.privatePlayer.stop()
    }

    func playNext(){
        self.privatePlayer.requestNextAndPlay()
    }
    
    func playPrev(){
        self.privatePlayer.requestPrevAndPlay()
    }

    

//    func getActivePlaylist() -> [TrackItem] {
//        return DBManager.sharedInstance.getActivePlaylist()
//    }

    //add tracks from Playlust to the Active playlist
    func addPlaylistToPlayQueue(_ item:PlaylistItem) {
        DBManager.sharedInstance.addPlaylistWithID(item.id)
        self.privatePlayer.play()
    }
    
    //add tracks to the Active playlist
    func addTracksToPlayQueue(_ list:[TrackItem]) {
        DBManager.sharedInstance.addPlaylistItems(list, finish: {
            self.privatePlayer.play()
        })
    }
    
    //play tack separately of playlist. Active playlist will not be changed
    func PlayTrackStandalone(_ item:TrackItem) {
        var media = PrivatPlayerMediaItem()
        media.url = item.getFileURL()
        media.title = item.title
        media.artist = item.artist
        self.privatePlayer.play(media)
    }
    //will replace whole Active playlist
    func newPlaylistQueue(_ item:PlaylistItem) {
        DBManager.sharedInstance.replacePlaylistWithID(item.id)
    }
}

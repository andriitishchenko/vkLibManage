//
//  Player.swift
//  vkLibManage
//
//  Created by Andrii Tiischenko on 10/19/16.
//  Copyright © 2016 Andrii Tiischenko. All rights reserved.
//

import UIKit
import MediaPlayer
import Jukebox

//@objc(Player)
class Player: NSObject, PrivatPlayerDelegate {
//    private var jukebox : Jukebox!
    
    private let privatePlayer = PrivatPlayer()
    
    static let sharedInstance: Player = Player()
    
    //private override
    private override init() {
        // begin receiving remote events
        super.init()
        
        
        
        // configure jukebox
        //self.jukebox = Jukebox(delegate: self, items: [])!
        
//        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        self.privatePlayer.delegate = self
//        self.privatePlayer.play()
    }
    
//    deinit {
//        UIApplication.shared.endReceivingRemoteControlEvents()
//    }
//    
//    
    func addToQueue(_ item:TrackItem){
//        self.jukebox.append(item: JukeboxItem (URL: URL(string: "http://www.noiseaddicts.com/samples_1w72b820/2228.mp3")!), loadingAssets: false)
    }
//
//    func clearQueue(){
//        self.jukebox.play()
//    }
//    
//    
//    // MARK:- JukeboxDelegate -
//    
//    func jukeboxDidLoadItem(_ jukebox: Jukebox, item: JukeboxItem) {
//        print("Jukebox did load: \(item.URL.lastPathComponent)")
//    }
//    
//    func jukeboxPlaybackProgressDidChange(_ jukebox: Jukebox) {
//        
//        if let currentTime = jukebox.currentItem?.currentTime, let duration = jukebox.currentItem?.meta.duration {
////            let value = Float(currentTime / duration)
////            slider.value = value
////            populateLabelWithTime(currentTimeLabel, time: currentTime)
////            populateLabelWithTime(durationLabel, time: duration)
//        } else {
////            resetUI()
//        }
//    }
//    
//    func jukeboxStateDidChange(_ jukebox: Jukebox) {
//        
//        UIView.animate(withDuration: 0.3, animations: { () -> Void in
////            self.indicator.alpha = jukebox.state == .loading ? 1 : 0
////            self.playPauseButton.alpha = jukebox.state == .loading ? 0 : 1
////            self.playPauseButton.isEnabled = jukebox.state == .loading ? false : true
//        })
//        
//        if jukebox.state == .ready {
////            playPauseButton.setImage(UIImage(named: "playBtn"), for: UIControlState())
//        } else if jukebox.state == .loading  {
////            playPauseButton.setImage(UIImage(named: "pauseBtn"), for: UIControlState())
//        } else {
////            volumeSlider.value = jukebox.volume
//            let imageName: String
//            switch jukebox.state {
//            case .playing, .loading:
//                imageName = "pauseBtn"
//            case .paused, .failed, .ready:
//                imageName = "playBtn"
//            }
////            playPauseButton.setImage(UIImage(named: imageName), for: UIControlState())
//        }
//        
//        print("Jukebox state changed to \(jukebox.state)")
//    }
//    
//    func jukeboxDidUpdateMetadata(_ jukebox: Jukebox, forItem: JukeboxItem) {
//        print("Item updated:\n\(forItem)")
//    }
//    
//    
//    func remoteControlReceived(with event: UIEvent?) {
//        if event?.type == .remoteControl {
//            switch event!.subtype {
//            case .remoteControlPlay :
//                jukebox.play()
//            case .remoteControlPause :
//                jukebox.pause()
//            case .remoteControlNextTrack :
//                jukebox.playNext()
//            case .remoteControlPreviousTrack:
//                jukebox.playPrevious()
//            case .remoteControlTogglePlayPause:
//                if jukebox.state == .playing {
//                    jukebox.pause()
//                } else {
//                    jukebox.play()
//                }
//            default:
//                break
//            }
//        }
//    }
    
    
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

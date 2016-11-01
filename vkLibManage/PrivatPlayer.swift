//
//  PrivatPlayer.swift
//  vkLibManage
//
//  Created by Andrii Tiischenko on 10/25/16.
//  Copyright © 2016 Andrii Tiischenko. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import MediaPlayer

@objc public enum PrivatPlayerStatus:Int {
    case Play
    case Stop
}

public struct PrivatPlayerMediaItem  {
    var artist:String? = nil
    var title:String? = nil
    var album:String? = nil
    var artwork:UIImage? = nil
    var duration:Double = 0
    var time:Float = 0
    var url:URL? = nil
}

private extension PrivatPlayerMediaItem{

    mutating func update(_ item: AVMetadataItem) {
        switch item.commonKey
        {
        case "title"? :
            if title != nil { title = item.value as? String }
        case "albumName"? :
            if album != nil { album = item.value as? String }
        case "artist"? :
            if artist != nil { artist = item.value as? String }
        case "artwork"? :
            if artwork != nil { updateArtwork(item) }
        default :
            break
        }
    }
    
    mutating func updateArtwork(_ item: AVMetadataItem) {
        guard let value = item.value else { return }
        let copiedValue: AnyObject = value.copy(with: nil) as AnyObject
        
        if let dict = copiedValue as? [AnyHashable: Any] {
            //AVMetadataKeySpaceID3
            if let imageData = dict["data"] as? Data {
                artwork = UIImage(data: imageData)
            }
        } else if let data = copiedValue as? Data{
            //AVMetadataKeySpaceiTunes
            artwork = UIImage(data: data)
        }
    }
}

public struct PrivatPlayerUpdate {
    var isActive:Bool
    var duration:Double
    var time:Double
}

public protocol PrivatPlayerDelegate:class {
    func privatPlayerGetNextTrack() -> PrivatPlayerMediaItem?
    func privatPlayerGetPrevTrack() -> PrivatPlayerMediaItem?
    func privatPlayerDidStartedTrack()
    func privatPlayerDidFinishedTrack()
}

public protocol PrivatPlayerDelegateUI:class {
    func privatPlayerUIPlaySatus(_ status:PrivatPlayerStatus)
    func privatPlayerUIUpdate(_ item: PrivatPlayerUpdate)
    func privatPlayerUIError(_ message: String?, error: Error?)
    func privatPlayerUITick(_ value:Float)
    
}

/*
 This is one instance of player item. It not manage the playlist. It just play the data what you give to it.
*/
class PrivatPlayer: NSObject {
    private var PrivatPlayerKVOContext = 0
    static let assetKeysRequiredToPlay = [
        "playable",
        "hasProtectedContent"
    ]
    
    weak var delegate    :   PrivatPlayerDelegate?
    weak var delegateUI  :   PrivatPlayerDelegateUI?
    let player = AVPlayer()
    
    private var playerItem: AVPlayerItem? = nil {
        didSet {
            if self.playerItem != nil {
                NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidPlayToEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
                
                self.metaInfo?.duration = CMTimeGetSeconds((playerItem?.duration)!)
                
                self.extractMeta(self.playerItem!, onUpdate: { item in
                    self.metaInfo?.update(item)
                })
                
                player.replaceCurrentItem(with: self.playerItem)
                player.play()
            }
            else{
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
            }
        }
    }
    
    var currentTime: Double {
        get {
            return CMTimeGetSeconds(player.currentTime())
        }
        set {
            let newTime = CMTimeMakeWithSeconds(newValue, 1)
            player.seek(to: newTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        }
    }
    
    var duration: Double {
        guard let currentItem = player.currentItem else { return 0.0 }
        
        return CMTimeGetSeconds(currentItem.duration)
    }
    
    var rate: Float {
        get {
            return player.rate
        }
        
        set {
            player.rate = newValue
        }
    }
    
    var asset: AVURLAsset? {
        didSet {
            guard let newAsset = asset else { return }
            asynchronouslyLoadURLAsset(newAsset)
        }
    }
    
    var metaInfo:PrivatPlayerMediaItem? = nil {
        didSet{
            guard metaInfo != nil else { return }
            self.updateInfoCenter()
        }
    }

    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        
        return formatter
    }()
    
    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
    
    
    private var timeObserverToken: Any?
    
    
   func playPause() {
        if player.rate != 1.0 {
            if currentTime == duration {
                currentTime = 0.0
            }
            player.play()
        }
        else {
            player.pause()
        }
    }
    
    func rewindButtonWasPressed() {
        rate = max(player.rate - 2.0, -2.0)
    }
    
    func fastForwardButtonWasPressed() {
        rate = min(player.rate + 2.0, 2.0)
    }
    
    func seekTimeToPosition(_ time: Double) {
        currentTime = time
    }
    
    func play(){
        if (self.playerItem != nil) {
            self.player.play()
        }
        else {
            self.requestNextAndPlay()
        }
    }
    
    private func updateasset(){
        if let url:URL = self.metaInfo?.url {
            asset = AVURLAsset(url: url, options: nil)
        }
    }
    
    func play(_ media:PrivatPlayerMediaItem){
        self.metaInfo = media
        self.updateasset()
    }
    
    func requestNextAndPlay(){
        self.metaInfo = self.delegate?.privatPlayerGetNextTrack()
        self.updateasset()
    }
    
    func requestPrevAndPlay(){
        self.metaInfo = self.delegate?.privatPlayerGetPrevTrack()
        self.updateasset()
     }
    
    
    
    
    
    func play(_ url: URL!){
        asset = AVURLAsset(url: url, options: nil)
    }

    
    func asynchronouslyLoadURLAsset(_ newAsset: AVURLAsset) {
        newAsset.loadValuesAsynchronously(forKeys: PrivatPlayer.assetKeysRequiredToPlay) {
            DispatchQueue.main.async {
                guard newAsset == self.asset else { return }
                
                for key in PrivatPlayer.assetKeysRequiredToPlay {
                    var error: NSError?
                    
                    if newAsset.statusOfValue(forKey: key, error: &error) == .failed {
                        let stringFormat = NSLocalizedString("error.asset_key_%@_failed.description", comment: "Can't use this AVAsset because one of it's keys failed to load")
                        let message = String.localizedStringWithFormat(stringFormat, key)
                        self.handleErrorWithMessage(message, error: error)
                        return
                    }
                }
                
                if !newAsset.isPlayable || newAsset.hasProtectedContent {
                    let message = NSLocalizedString("error.asset_not_playable.description", comment: "Can't use this AVAsset because it isn't playable or has protected content")
                    self.handleErrorWithMessage(message)
                    return
                }
                
                self.playerItem = AVPlayerItem(asset: newAsset)
            }
        }
    }
    
    // MARK: - KVO Observation
    
    // Update our UI when player or `player.currentItem` changes.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        // Make sure the this KVO callback was intended for this view controller.
        guard context == &PrivatPlayerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(PrivatPlayer.player.currentItem.duration) {
            // Update timeSlider and enable/disable controls when duration > 0.0
            
            /*
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            let newDuration: CMTime
            if let newDurationAsValue = change?[NSKeyValueChangeKey.newKey] as? NSValue {
                newDuration = newDurationAsValue.timeValue
            }
            else {
                newDuration = kCMTimeZero
            }
            
            let hasValidDuration = newDuration.isNumeric && newDuration.value != 0
            let newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0
            let currentTime = hasValidDuration ? CMTimeGetSeconds(player.currentTime()) : 0.0
            
            let update:PrivatPlayerUpdate = PrivatPlayerUpdate(
                isActive : hasValidDuration,
                duration : newDurationSeconds,
                time : currentTime
            )
            self.delegateUI?.privatPlayerUIUpdate(update)
        }
        else if keyPath == #keyPath(PrivatPlayer.player.rate) {
            // Update `playPauseButton` image.
            
            let newRate = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).doubleValue
            
            let st:PrivatPlayerStatus = newRate == 1.0 ? .Stop : .Play
            self.delegateUI?.privatPlayerUIPlaySatus(st)
        }
        else if keyPath == #keyPath(PrivatPlayer.player.currentItem.status) {
            // Display an error if status becomes `.Failed`.
            
            /*
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            let newStatus: AVPlayerItemStatus
            
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.intValue)!
            }
            else {
                newStatus = .unknown
            }
            
            if newStatus == .failed {
                handleErrorWithMessage(player.currentItem?.error?.localizedDescription, error:player.currentItem?.error)
            }
        }
    }
    
    // Trigger KVO for anyone observing our properties affected by player and player.currentItem
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        let affectedKeyPathsMappingByKey: [String: Set<String>] = [
            "duration":     [#keyPath(PrivatPlayer.player.currentItem.duration)],
            "rate":         [#keyPath(PrivatPlayer.player.rate)]
        ]
        
        return affectedKeyPathsMappingByKey[key] ?? super.keyPathsForValuesAffectingValue(forKey: key)
    }
    
    // MARK: - Error Handling
    func handleErrorWithMessage(_ message: String?, error: Error? = nil) {
        NSLog("||| Error occured with message:/n \(message), error: \(error).")
        self.delegateUI?.privatPlayerUIError(message, error: error)
    }

    
    // MARK: - Observers Handling
    func registerUpdates()
    {
        addObserver(self, forKeyPath: #keyPath(PrivatPlayer.player.currentItem.duration), options: [.new, .initial], context: &PrivatPlayerKVOContext)
        addObserver(self, forKeyPath: #keyPath(PrivatPlayer.player.rate), options: [.new, .initial], context: &PrivatPlayerKVOContext)
        addObserver(self, forKeyPath: #keyPath(PrivatPlayer.player.currentItem.status), options: [.new, .initial], context: &PrivatPlayerKVOContext)

        // Make sure we don't have a strong reference cycle by only capturing self as weak.
        let interval = CMTimeMake(1, 1)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [unowned self] time in
            let timeElapsed = Float(CMTimeGetSeconds(time))
            self.delegateUI?.privatPlayerUITick(timeElapsed)
        }
    }
    
    func unregisterUpdates(){
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
        
        player.pause()
        
        removeObserver(self, forKeyPath: #keyPath(PrivatPlayer.player.currentItem.duration), context: &PrivatPlayerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(PrivatPlayer.player.rate), context: &PrivatPlayerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(PrivatPlayer.player.currentItem.status), context: &PrivatPlayerKVOContext)
    }
    
    
    @objc private func playerItemDidPlayToEnd(_ notification : Notification){
        self.requestNextAndPlay()
    }
    

    
//    
//    
//    func remoteControlReceivedWithEvent(event: UIEvent) {
//        self.remoteControlReceived(with: event)
//    }
//    
//    
//    func remoteControlReceived(with event: UIEvent?) {
//
//        if event?.type == .remoteControl {
//            switch event!.subtype {
//            case .remoteControlPlay :
//                self.player.play()
//            case .remoteControlPause :
//                self.player.pause()
//            case .remoteControlNextTrack :
//                self.requestNextAndPlay()
//            case .remoteControlPreviousTrack:
//                self.requestPrevAndPlay()
//            case .remoteControlTogglePlayPause:
//                self.playPause()
//            default:
//                break
//            }
//        }
//    }

    
//    - (void)configureNowPlayingInfo:(MPMediaItem*)item
//    {
//    MPNowPlayingInfoCenter* info = [MPNowPlayingInfoCenter defaultCenter];
//    NSMutableDictionary* newInfo = [NSMutableDictionary dictionary];
//    NSSet* itemProperties = [NSSet setWithObjects:
//    MPMediaItemPropertyTitle,
//    MPMediaItemPropertyArtist,
//    MPMediaItemPropertyPlaybackDuration,
//    MPNowPlayingInfoPropertyElapsedPlaybackTime,
//    nil];
//    
//    [item enumerateValuesForProperties:itemProperties
//    usingBlock:^(NSString *property, id value, BOOL *stop) {
//    [newInfo setObject:value forKey:property];
//    }];
//    
//    info.nowPlayingInfo = newInfo;
//    }

    
    private func extractMeta(_ mediaItem:AVPlayerItem, onUpdate:@escaping (AVMetadataItem)->Void)
    {
        DispatchQueue.global(qos: .background).async {
            let metadataArray = mediaItem.asset.commonMetadata
            for item in metadataArray
            {
                item.loadValuesAsynchronously(forKeys: [AVMetadataKeySpaceCommon], completionHandler: { () -> Void in
                    DispatchQueue.main.async {
                        onUpdate(item)
                    }
                })
            }
        }
    }
    
    
    private func updateInfoCenter() {

        if let item = self.metaInfo
        {
            var info : [String : AnyObject] = [
                MPMediaItemPropertyPlaybackDuration : item.duration as AnyObject,
                MPMediaItemPropertyTitle : item.title as AnyObject,
                MPNowPlayingInfoPropertyElapsedPlaybackTime : item.time as AnyObject,
//                MPNowPlayingInfoPropertyPlaybackQueueCount :1 as AnyObject,
//                MPNowPlayingInfoPropertyPlaybackQueueIndex : 0 as AnyObject,
                MPMediaItemPropertyMediaType : MPMediaType.anyAudio.rawValue as AnyObject
            ]
            
            if let artist = item.artist {
                info[MPMediaItemPropertyArtist] = artist as AnyObject?
            }
            
            if let album = item.album {
                info[MPMediaItemPropertyAlbumTitle] = album as AnyObject?
            }
            
            if let img = item.artwork {
                info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: img)
            }
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        }
    }

    
    
   @objc fileprivate func _pause() {
        self.player.pause()
    }
    
   @objc private func _play() {
        self.player.play()
    }
    
   @objc private func _next() {
        self.requestNextAndPlay()
    }
    
   @objc private func _prev() {
        self.requestPrevAndPlay()
    }
    
   @objc private func _togle() {
        self.playPause()
    }
    
    
    //https://developer.apple.com/library/content/documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/Remote-ControlEvents/Remote-ControlEvents.html
    
    //https://developer.apple.com/reference/mediaplayer/mpremotecommandcenter
    
    override init() {
        super.init()
        let commandCenter:MPRemoteCommandCenter = MPRemoteCommandCenter.shared()
//        commandCenter.pauseCommand.enabled = true
        commandCenter.pauseCommand.addTarget(self, action: #selector(self._pause))
        commandCenter.playCommand.addTarget(self, action: #selector(self._play))
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(self._next))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(self._prev))
        commandCenter.togglePlayPauseCommand.addTarget(self, action: #selector(self._togle))
        self.registerUpdates()
    }
    
    deinit {
        self.unregisterUpdates()
        
    }
}

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
    var artist:String?
    var title:String?
    var album:String?
    var artwork:UIImage?
    var duration:Float = 0
    var time:Float = 0
    
}

public struct PrivatPlayerUpdate {
    var isActive:Bool
    var duration:Float
    var time:Float
}

public protocol PrivatPlayerDelegate:class {
    func privatPlayerGetNextTrack() -> URL
    func privatPlayerGetPrevTrack() -> URL
    func privatPlayerDidStartedTrack()
    func privatPlayerDidFinishedTrack()
    func privatPlayerGetMediaInfo() -> PrivatPlayerMediaItem?
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
    let commandCenter:MPRemoteCommandCenter = MPRemoteCommandCenter.shared()
    
    
    public var remoteNottification:Bool = false {
        didSet {
//            if (self.remoteNottification)
//            {
////                self.canBecomeFirstResponder()
//                UIApplication.shared.beginReceivingRemoteControlEvents()
//            }
//            else
//            {
//                UIApplication.shared.endReceivingRemoteControlEvents()
//            }
        }
    }
    
    private var playerItem: AVPlayerItem? = nil {
        didSet {
            player.replaceCurrentItem(with: self.playerItem)
            player.play()
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
    
    func requestNextAndPlay(){
    
        let url:URL? = (self.delegate?.privatPlayerGetNextTrack())!
        if (url == nil){
            self.requestNextAndPlay()
            return
        }
        asset = AVURLAsset(url: url!, options: nil)
    }
    
    func requestPrevAndPlay(){
        
        let url:URL? = (self.delegate?.privatPlayerGetPrevTrack())!
        if (url == nil){
            self.requestPrevAndPlay()
            return
        }
        asset = AVURLAsset(url: url!, options: nil)
    }
    
    
    
    
    
    func play(_ url: URL!){
        asset = AVURLAsset(url: url, options: nil)
    }

    
    func asynchronouslyLoadURLAsset(_ newAsset: AVURLAsset) {
        /*
         Using AVAsset now runs the risk of blocking the current thread (the
         main UI thread) whilst I/O happens to populate the properties. It's
         prudent to defer our work until the properties we need have been loaded.
         */
        newAsset.loadValuesAsynchronously(forKeys: PrivatPlayer.assetKeysRequiredToPlay) {
            /*
             The asset invokes its completion handler on an arbitrary queue.
             To avoid multiple threads using our internal state at the same time
             we'll elect to use the main thread at all times, let's dispatch
             our handler to the main queue.
             */
            DispatchQueue.main.async {
                /*
                 `self.asset` has already changed! No point continuing because
                 another `newAsset` will come along in a moment.
                 */
                guard newAsset == self.asset else { return }
                
                /*
                 Test whether the values of each of the keys we need have been
                 successfully loaded.
                 */
                for key in PrivatPlayer.assetKeysRequiredToPlay {
                    var error: NSError?
                    
                    if newAsset.statusOfValue(forKey: key, error: &error) == .failed {
                        let stringFormat = NSLocalizedString("error.asset_key_%@_failed.description", comment: "Can't use this AVAsset because one of it's keys failed to load")
                        
                        let message = String.localizedStringWithFormat(stringFormat, key)
                        
                        self.handleErrorWithMessage(message, error: error)
                        
                        return
                    }
                }
                
                // We can't play this asset.
                if !newAsset.isPlayable || newAsset.hasProtectedContent {
                    let message = NSLocalizedString("error.asset_not_playable.description", comment: "Can't use this AVAsset because it isn't playable or has protected content")
                    
                    self.handleErrorWithMessage(message)
                    
                    return
                }
                
                /*
                 We can play this asset. Create a new `AVPlayerItem` and make
                 it our player's current item.
                 */
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
            let currentTime = hasValidDuration ? Float(CMTimeGetSeconds(player.currentTime())) : 0.0
            
            let update:PrivatPlayerUpdate = PrivatPlayerUpdate(
                isActive : hasValidDuration,
                duration : Float(newDurationSeconds),
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
        NSLog("Error occured with message: \(message), error: \(error).")
        self.delegateUI?.privatPlayerUIError(message, error: error)
    }
    
//    override func canBecomeFirstResponder() -> Bool {
//        return true
//    }
    
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
//    NSSet* itemProperties = [NSSet setWithObjects:MPMediaItemPropertyTitle,
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

    fileprivate func updateInfoCenter() {

        if let item = self.delegate?.privatPlayerGetMediaInfo()
        {
            var nowPlayingInfo : [String : AnyObject] = [
                MPMediaItemPropertyPlaybackDuration : item.duration as AnyObject,
                MPMediaItemPropertyTitle : item.title as AnyObject,
                MPNowPlayingInfoPropertyElapsedPlaybackTime : item.time as AnyObject,
                MPNowPlayingInfoPropertyPlaybackQueueCount :1 as AnyObject,
                MPNowPlayingInfoPropertyPlaybackQueueIndex : 0 as AnyObject,
                MPMediaItemPropertyMediaType : MPMediaType.anyAudio.rawValue as AnyObject
            ]
            
            if let artist = item.artist {
                nowPlayingInfo[MPMediaItemPropertyArtist] = artist as AnyObject?
            }
            
            if let album = item.album {
                nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album as AnyObject?
            }
            
            if let img = item.artwork {
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: img)
            }
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
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
//        self.commandCenter.pauseCommand.enabled = true
        self.commandCenter.pauseCommand.addTarget(self, action: #selector(self._pause))
        self.commandCenter.playCommand.addTarget(self, action: #selector(self._play))
        self.commandCenter.nextTrackCommand.addTarget(self, action: #selector(self._next))
        self.commandCenter.previousTrackCommand.addTarget(self, action: #selector(self._prev))
        self.commandCenter.togglePlayPauseCommand.addTarget(self, action: #selector(self._togle))
    }
    
    deinit {
        self.unregisterUpdates()
        self.remoteNottification = false
    }
}

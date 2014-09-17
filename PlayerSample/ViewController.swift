//
//  ViewController.swift
//  PlayerSample
//
//  Created by Shingai Yoshimi on 8/30/14.
//  Copyright (c) 2014 Shingai Yoshimi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var seekber: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var playerMenu: UIView!
    
    @IBOutlet weak var singleTap: UITapGestureRecognizer!
    @IBOutlet weak var doubleTap: UITapGestureRecognizer!
    
    @IBOutlet weak var videoPlayerView: AVPlayerView!
    var playerItem: AVPlayerItem? = nil
    var videoPlayer: AVPlayer? = nil
    var videoTimeObserver: AnyObject? = nil
    var playingRateAfterScrub: Float = 0
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // サンプル動画のパスを取得
        let bundle = NSBundle.mainBundle()
        let url: NSURL = NSBundle.mainBundle().URLForResource("sample", withExtension: "mp4")!
        
        // 動画のパスを指定してplayerItemを生成
        self.playerItem = AVPlayerItem(URL: url)
        
        // 上で生成したplayerItemを指定してplayerを生成
        self.videoPlayer = AVPlayer(playerItem: self.playerItem)
        
        // playerとplayerの表示サイズを指定
        self.videoPlayerView.setPlayer(self.videoPlayer!)
        self.videoPlayerView.setVideoFillMode(AVLayerVideoGravityResizeAspect)
        
        // 動画が終了した時に呼ばれるnotificationを登録
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItem)
        
        // 再生時間とシークバー位置の更新
        self.videoTimeObserver = self.videoPlayer!.addPeriodicTimeObserverForInterval(CMTimeMake(150, 600),
            queue: dispatch_get_main_queue(),
            usingBlock: {[unowned self](CMTime) in
                self.syncSeekber()
                self.updateTimeLabel()
        })
        
        self.seekber.minimumTrackTintColor = UIColor.whiteColor()
        self.seekber.maximumTrackTintColor = UIColor.blackColor()
        self.seekber.setValue(0, animated: false)
        self.syncPlayPauseButtonImage()
        self.updateTimeLabel()
        
        self.singleTap.requireGestureRecognizerToFail(self.doubleTap)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    // MARK: - Player Notifications
    
    func playerItemDidReachEnd(notification: NSNotification) {
        self.syncPlayPauseButtonImage()
        self.seekToTime(0)
    }
    
    
    // MARK: - Player Item
    
    func isPlaying() -> Bool {
        return playingRateAfterScrub != 0 || self.videoPlayer!.rate != 0
    }
    
    func playerItemDuration() -> CMTime {
        let playerItem: AVPlayerItem = self.videoPlayer!.currentItem
        if playerItem.status == .ReadyToPlay {
            return playerItem.duration
        }
        
        return kCMTimeInvalid
    }
    
    
    // MARK: - Player Appearance
    
    func syncSeekber() {
        let playerDuration: CMTime = self.playerItemDuration()
        
        if !playerDuration.isValid {
            self.seekber.minimumValue = 0
            return
        }
        
        let duration: Double = CMTimeGetSeconds(playerDuration)
        let currentTime: Double = CMTimeGetSeconds(self.videoPlayer!.currentTime())
        
        let progress: Float = Float(currentTime/duration)
        self.seekber.setValue(progress, animated: true)
    }
    
    func updateTimeLabel() {
        let playerDuration: CMTime = self.playerItemDuration()
        
        if !playerDuration.isValid {
            return
        }
        
        let duration: Double = CMTimeGetSeconds(playerDuration)
        let currentTime: Double = CMTimeGetSeconds(self.videoPlayer!.currentTime())
        
        let elapsedTimeMin: Int = Int(currentTime/60)
        let elapsedTimeSec: Int = Int(currentTime) - elapsedTimeMin*60
        
        let remainingTimeMin: Int = Int((duration - currentTime)/60)
        let remainingTimeSec: Int = Int(duration - currentTime) - remainingTimeMin*60
        
        self.elapsedTimeLabel.text = NSString(format:"%02d",elapsedTimeMin) + ":" + NSString(format:"%02d",elapsedTimeSec)
        self.remainingTimeLabel.text = "-" + NSString(format:"%02d",remainingTimeMin) + ":" + NSString(format:"%02d",remainingTimeSec)
    }
    
    
    // MARK: - Play & Pause
    
    func play() {
        self.videoPlayer!.play()
    }
    
    func pause() {
        self.videoPlayer!.pause()
    }
    
    @IBAction func playOrPause(sender: AnyObject) {
        if self.isPlaying() {
            self.pause()
        } else {
            self.play()
        }
        
        self.syncPlayPauseButtonImage()
    }
    
    func syncPlayPauseButtonImage() {
        if self.isPlaying() {
            self.playPauseButton.setImage(UIImage(named:"pause.png"), forState: .Normal)
        } else {
            self.playPauseButton.setImage(UIImage(named:"play.png"), forState: .Normal)
        }
    }
    
    
    // MARK: - Seek

    @IBAction func beginScrubbing(slider: UISlider) {
        self.playingRateAfterScrub = self.videoPlayer!.rate
        self.pause()
    }
    
    @IBAction func endScrubbing(slider: UISlider) {
        if self.playingRateAfterScrub != 0 {
            self.play()
            self.playingRateAfterScrub = 0
        }
    }
    
    @IBAction func scrub(slider: UISlider) {
        self.seekToTime(Double(slider.value))
    }
    
    func isScrubbing() -> Bool {
        return playingRateAfterScrub != 0;
    }

    
    @IBAction func back() {
        self.seekToTime(0)
    }
    
    @IBAction func next() {
        self.seekToTime(1)
    }
    
    func seekToTime(position: Double) {
        let playerDuration: CMTime = self.playerItemDuration()
        
        if !playerDuration.isValid {
            self.seekber.minimumValue = 0
            return
        }
        
        let duration: Double  = CMTimeGetSeconds(playerDuration);
        
        let currentTime: Double = CMTimeGetSeconds(videoPlayer!.currentTime())
        if (currentTime <= 0 && position == 0) || (currentTime >= duration && position == 1) {
            return;
        }
        
        let time: Double = duration * position
        self.videoPlayer!.seekToTime(CMTimeMakeWithSeconds(time, Int32(NSEC_PER_SEC)))
    }
    
    // MARK: - Tap Gesture
    @IBAction func hideMenu() {
        if self.playerMenu.hidden {
            self.playerMenu.hidden = false
            UIView.animateWithDuration(0.25, animations: {
                self.playerMenu.alpha = 1
            })
            
        } else {
            UIView.animateWithDuration(0.25, animations: {
                self.playerMenu.alpha = 0
            }, completion: { (value: Bool) in
                self.playerMenu.hidden = true
            })
        }
    }
    
    @IBAction func zoomPlayer() {
        if self.videoPlayerView.videoFillMode() == AVLayerVideoGravityResizeAspect {
            self.videoPlayerView.setVideoFillMode(AVLayerVideoGravityResizeAspectFill)
        } else {
            self.videoPlayerView.setVideoFillMode(AVLayerVideoGravityResizeAspect)
        }
    }
    
}

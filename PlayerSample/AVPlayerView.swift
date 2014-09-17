//
//  AVPlayerView.swift
//  PlayerSample
//
//  Created by Shingai Yoshimi on 8/30/14.
//  Copyright (c) 2014 Shingai Yoshimi. All rights reserved.
//

import UIKit
import AVFoundation

class AVPlayerView : UIView {
    
    // UIViewのサブクラスを作りlayerClassメソッドをオーバーライドしてAVPlayerLayerに差し替える
    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }
    
    func player() -> AVPlayer {
        let layer: AVPlayerLayer = self.layer as AVPlayerLayer
        return layer.player!
    }
    
    func setPlayer(player: AVPlayer) {
        let layer: AVPlayerLayer = self.layer as AVPlayerLayer
        layer.player = player
    }
    
    func setVideoFillMode(fillMode: NSString) {
        let layer: AVPlayerLayer = self.layer as AVPlayerLayer
        layer.videoGravity = fillMode
    }
    
    func videoFillMode() -> NSString {
        let layer: AVPlayerLayer = self.layer as AVPlayerLayer
        return layer.videoGravity
    }
}
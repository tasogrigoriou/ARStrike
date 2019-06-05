//
//  AVPlayer+Helpers.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 1/8/19.
//  Copyright © 2019 Taso Grigoriou. All rights reserved.
//

import AVFoundation

extension AVPlayer {
    convenience init?(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        self.init(playerItem: playerItem)
    }
    
    convenience init?(name: String, extension ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            return nil
        }
        self.init(url: url)
    }
    
    func playFromStart() {
        seek(to: CMTimeMake(value: 0, timescale: 1))
        play()
    }
    
    func playLoop() {
        playFromStart()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.currentItem, queue: nil) { notification in
            if self.timeControlStatus == .playing {
                self.playFromStart()
            }
        }
    }
    
    func endLoop() {
        pause()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self)
    }
}

//
//  GameClock.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 11/11/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

/* Abstract:
Central static class to keep track of game time.
*/

import Foundation

class GameClock {
    //! The start time of the app.
    // Note: Uninitialized time/startTime are set to -1.0 so it can be checked in a lazy initialization
    private static var startTime = TimeInterval(-1.0)
    
    //! The time given by the renderer's updateAtTime
    private(set) static var time = TimeInterval(-1.0)
    
    //! The time since the app started
    private(set) static var timeSinceStart = TimeInterval(0.0)
    
    //! The time changed since last frame
    private(set) static var deltaTime = TimeInterval(0.0)
    
    //! The frame count since the app started
    private(set) static var frameCount = 0
    
    private static var levelStartTime = TimeInterval(-1.0)
    static var timeSinceLevelStart: TimeInterval { return GameClock.time - levelStartTime }
    
    static func setLevelStartTime() {
        levelStartTime = GameClock.time
    }
    
    static func updateAtTime(time: TimeInterval) {
        if startTime == -1.0 {
            startTime = time
            self.time = time
            return
        }
        
        deltaTime = time - self.time
        timeSinceStart = time - self.startTime
        self.time = time
        frameCount += 1
    }
}

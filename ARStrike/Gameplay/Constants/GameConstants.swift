//
//  GameConstants.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 12/11/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

struct GameConstants {
    static let maxPlayerHealth: Float = 200
    static let defaultEnemyDamage: Float = 25
    static let defaultPoints: Float = 75
    
    static let maxXPosition: CGFloat = 2.0
    static let maxZPosition: CGFloat = 2.0
    
    static let enemyNodeNames: [String] = [
        "pickle_low",
        "picklerick",
        "meeseeks_box"
    ]
    
    static let HIGH_SCORE_ID = "com.taso.RickAndMortyAR.HighScore"
    static let HIGH_LEVEL_ID = "com.taso.RickAndMortyAR.HighLevel"
    
    static var audioEnabled: Bool = true
}

struct SCNNodeCache {
    static var cachedNodes: [String: SCNNode] = [:]
}

struct Audio {
    static let portalGun: String = "portal_gun_fire.wav"
}

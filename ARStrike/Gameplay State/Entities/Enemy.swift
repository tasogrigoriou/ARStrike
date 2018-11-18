//
//  GameEnemy.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 11/11/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

class Enemy: SCNNode {
    static let name: String = NSStringFromClass(Enemy.self)
    
    let node = SCNNode.loadSCNAsset(modelFileName: "MeeseeksBox")
    
    let defaultPosition = SCNVector3(1.2, -1, -12.5) // position weapon at bottom right of screen (w.r.t. camera)
    
    func update(deltaTime seconds: TimeInterval) {
        
    }
}

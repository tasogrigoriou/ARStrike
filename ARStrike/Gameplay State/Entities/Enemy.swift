//
//  Enemy.swift
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
    
    let node = SCNNode.loadSCNAsset(modelFileName: "meeseeks_box")
    
    override init() {
        node?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node?.physicsBody!.categoryBitMask = CollisionMask.enemy.rawValue
        node?.physicsBody!.isAffectedByGravity = false
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(deltaTime seconds: TimeInterval) {

    }
}

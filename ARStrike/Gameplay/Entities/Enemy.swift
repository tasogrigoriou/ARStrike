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
    
    let node: SCNNode?
    
    let speed: Float
    let duration: Float
    
    init(modelFileName: String, speed: Float, duration: Float) {
        self.speed = speed
        self.duration = duration
        node = SCNNode.loadSCNAsset(modelFileName: modelFileName)
        node?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node?.physicsBody!.categoryBitMask = CollisionMask.enemy.rawValue
        node?.physicsBody!.isAffectedByGravity = false
        node?.physicsBody!.velocityFactor = SCNVector3(speed, speed, speed)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyRandomDirectionalForce() {
        let force = SCNVector3(Double.random(in: -0.1..<0), Double.random(in: -0.1..<0), Double.random(in: -0.3..<0))
        node?.physicsBody?.applyForce(force, asImpulse: true)
    }
    
    func update(deltaTime seconds: TimeInterval) {

    }
}

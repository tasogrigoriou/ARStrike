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
    let fileName: String
    
    let node: SCNNode?
    
    let duration: Double // time it takes for enemy to move to new random position
    var cooldownPeriod: TimeInterval // time it takes for an enemy to begin attacking the player
    let attackTime: Double // time it takes for an enemy to move from current position to player position and make contact
    
    var isAttackingPlayer: Bool = false

    var lastTimePositionChanged: CFAbsoluteTime = 0
    
    init(modelFileName: String, duration: Double, cooldownPeriod: Double, attackTime: Double) {
        self.fileName = modelFileName
        self.duration = duration
        self.cooldownPeriod = cooldownPeriod
        self.attackTime = attackTime
        node = SCNNode.loadSCNAsset(modelFileName: modelFileName)
        node?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node?.physicsBody!.categoryBitMask = CollisionMask([.enemy]).rawValue
        node?.physicsBody!.collisionBitMask = CollisionMask([.bullet, .player]).rawValue
        node?.physicsBody!.contactTestBitMask = CollisionMask([.bullet, .player]).rawValue
        node?.physicsBody!.isAffectedByGravity = false
        node?.physicsBody!.velocity = SCNVector3Zero
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var enemyLocalFront: SCNVector3 {
        let localFront: SCNVector3
        switch fileName {
        case "pickle_low":
            localFront = SCNVector3(0, 0, 1)
        case "picklerick":
            localFront = SCNVector3(0, 0, 0)
        default:
            localFront = SCNVector3(0, 0, -1)
        }
        return localFront
    }
    
    func update(deltaTime seconds: TimeInterval) {
        let now = CFAbsoluteTimeGetCurrent()
        if !isAttackingPlayer {
            if lastTimePositionChanged == 0 || now - lastTimePositionChanged >= duration {
                lastTimePositionChanged = now
                moveToNewRandomPosition()
            }
        }
    }
    
    private func moveToNewRandomPosition() {
        guard let node = node else { return }
        
        let randomPosition = SCNVector3(CGFloat.random(in: -3...3), CGFloat.random(in: -1...1), CGFloat.random(in: -3...3))
        let moveAction = SCNAction.move(to: randomPosition, duration: duration)
        moveAction.timingMode = .easeInEaseOut
        node.runAction(moveAction)
        
        SCNTransaction.animate(duration: 3.0, animations: {
//            node.look(at: randomPosition, up: node.worldUp, localFront: enemyLocalFront)
        }, completion: {
            
        })
    }
}

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
        
    static var indexCounter = 0
    var index = 0
    static func resetIndexCounter() {
        indexCounter = 0
    }
    
    init(modelFileName: String, duration: Double, cooldownPeriod: Double, attackTime: Double) {
        self.index = Enemy.indexCounter
        Enemy.indexCounter += 1
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
    
    var childNodeWithGeometry: SCNNode? {
        let childNode: SCNNode?
        switch fileName {
        case "pickle_low":
            childNode = node?.childNode(withName: "pickle_rick_low", recursively: true)
        case "picklerick":
            childNode = node?.childNode(withName: "Highpoly_Highpoly", recursively: true)
        case "meeseeks_box":
            childNode = node
        default:
            childNode = nil
        }
        return childNode
    }
    
    var image: UIImage? {
        let image: UIImage?
        switch fileName {
        case "pickle_low":
            image = UIImage(named: "picke_bake.jpeg")
        case "picklerick":
            image = UIImage(named: "Highpoly_TXTR.png")
        case "meeseeks_box":
            image = UIImage(named: "meeseeksbox.png")
        default:
            image = nil
        }
        return image
    }
    
    func update(deltaTime seconds: TimeInterval, offsetPosition: SCNVector3) {
        let now = CFAbsoluteTimeGetCurrent()
        if !isAttackingPlayer {
            if lastTimePositionChanged == 0 || now - lastTimePositionChanged >= duration {
                lastTimePositionChanged = now
                moveToNewRandomPosition(with: offsetPosition)
            }
        }
    }
    
    private func moveToNewRandomPosition(with offsetPosition: SCNVector3) {
        guard let node = node else { return }
        
        let randomPosition: SCNVector3
        switch GameSettings.gameplayMode {
        case .normal:
            randomPosition = offsetPosition + SCNVector3(CGFloat.random(in: -2...2), CGFloat.random(in: -1...1), CGFloat.random(in: -2...2))
        case .sitting:
            randomPosition = offsetPosition + SCNVector3(CGFloat.random(in: -2...2), CGFloat.random(in: -1...1), CGFloat.random(in: -2...0))
        }
        
        node.runAction(.move(to: randomPosition, duration: duration))
    }
    
    // ex: offsetPos = (6, 0, 0) random = (-2, -1, -2), randomPos = (4, -1, -2)
    // ex: offsetPos = (-6, 0, 0) random = (-2, -1, -2), randomPos = (-8, -1, -2)

}

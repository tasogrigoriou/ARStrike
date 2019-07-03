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
    
    var node: SCNNode?
    
    let fileName: String
    let duration: Double // time it takes for enemy to move to new random position
    var cooldownPeriod: TimeInterval // time it takes for an enemy to begin attacking the player
    let attackTime: Double // time it takes for an enemy to move from current position to player position and make contact
    
    var isAttackingPlayer: Bool = false
    var lastTimePositionChanged: CFAbsoluteTime = 0
    var isNodeLoaded: Bool = false
        
    static var indexCounter = 0
    var index = 0
    static func resetIndexCounter() {
        indexCounter = 0
    }
    
    static var waitCounter: Double = 0
    var wait: Double = 0
    static func resetWaitCounter() {
        waitCounter = 0
    }
    
    init(components: EnemyComponents) {
        self.index = Enemy.indexCounter
        Enemy.indexCounter += 1
        self.wait = Enemy.waitCounter
        Enemy.waitCounter += 0.2
        self.fileName = components.name
        self.duration = components.duration
        self.cooldownPeriod = components.cooldownPeriod
        self.attackTime = components.attackTime
//        node = SCNNode.loadSCNAsset(modelFileName: components.name)
//        node?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
//        node?.physicsBody!.categoryBitMask = CollisionMask([.enemy]).rawValue
//        node?.physicsBody!.collisionBitMask = CollisionMask([.bullet, .player]).rawValue
//        node?.physicsBody!.contactTestBitMask = CollisionMask([.bullet, .player]).rawValue
//        node?.physicsBody!.isAffectedByGravity = false
//        node?.physicsBody!.velocity = SCNVector3Zero
        super.init()
    }
    
    func loadSCNNode() {
        node = SCNNode.loadSCNAsset(modelFileName: fileName)
        node?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node?.physicsBody!.categoryBitMask = CollisionMask([.enemy]).rawValue
        node?.physicsBody!.collisionBitMask = CollisionMask([.bullet, .player]).rawValue
        node?.physicsBody!.contactTestBitMask = CollisionMask([.bullet, .player]).rawValue
        node?.physicsBody!.isAffectedByGravity = false
        node?.physicsBody!.velocity = SCNVector3Zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var enemyLocalFront: SCNVector3 {
        let localFront: SCNVector3
        switch fileName {
        case "pickle_low": localFront = SCNVector3(0, 0, 1)
        case "picklerick": localFront = SCNVector3(0, 0, 0)
        default: localFront = SCNVector3(0, 0, -1)
        }
        return localFront
    }
    
    var childNodeWithGeometry: SCNNode? {
        let childNode: SCNNode?
        switch fileName {
        case "pickle_low": childNode = node?.childNode(withName: "pickle_rick_low", recursively: true)
        case "picklerick": childNode = node?.childNode(withName: "Highpoly_Highpoly", recursively: true)
        case "meeseeks_box": childNode = node
        default: childNode = nil
        }
        return childNode
    }
    
    var image: UIImage? {
        let image: UIImage?
        switch fileName {
        case "pickle_low": image = UIImage(named: "picke_bake.jpeg")
        case "picklerick": image = UIImage(named: "Highpoly_TXTR.png")
        case "meeseeks_box": image = UIImage(named: "meeseeksbox.png")
        default: image = nil
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
    
    func moveToNewRandomPosition(with offsetPosition: SCNVector3, addBreathing: Bool = true) {
        let randomPosition: SCNVector3
        switch GameSettings.gameplayMode {
        case .normal: randomPosition = normalModeRandomVector + offsetPosition
        case .sitting: randomPosition = sittingModeRandomVector + offsetPosition
        }
        node?.runAction(.move(to: randomPosition, duration: duration))
        if addBreathing {
//            addBreathingAnimation(to: node, dx: CGFloat(0.7), dy: CGFloat(0.7))
        }
    }
    
    private func addBreathingAnimation(to node: SCNNode?, dx: CGFloat = 0.0005, dy: CGFloat = 0.003) {
        let moveUp = SCNAction.moveBy(x: dx, y: dy, z: 0, duration: 1.2)
        moveUp.timingMode = .easeInEaseOut
        let moveDown = SCNAction.moveBy(x: -dx, y: -dy, z: 0, duration: 1.2)
        moveDown.timingMode = .easeInEaseOut
        let moveSequence = SCNAction.sequence([moveUp, moveDown])
        let breathingAction = SCNAction.repeatForever(moveSequence)
        node?.runAction(breathingAction)
    }
    
    private var normalModeRandomVector: SCNVector3 {
        return SCNVector3(CGFloat.random(in: -2 ... 2),
                          CGFloat.random(in: -1 ... 1),
                          CGFloat.random(in: -2 ... 2))
    }
    
    private var sittingModeRandomVector: SCNVector3 {
        return SCNVector3(CGFloat.random(in: -2 ... 2),
                          CGFloat.random(in: -1 ... 1),
                          CGFloat.random(in: -2 ... -0.5))
    }
    
    // ex: offsetPos = (6, 0, 0) random = (-2, -1, -2), randomPos = (4, -1, -2)
    // ex: offsetPos = (-6, 0, 0) random = (-2, -1, -2), randomPos = (-8, -1, -2)

}

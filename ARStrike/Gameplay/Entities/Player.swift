//
//  Player
//  ARStrike
//
//  Created by Taso Grigoriou on 11/29/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import Foundation
import ARKit
import SceneKit
import GameplayKit

class Player: SCNNode {
    static let name: String = NSStringFromClass(Player.self)
    
    let node = SCNNode.loadSCNAsset(modelFileName: "player") ?? SCNNode()
    var anchor: ARAnchor?
    
    var health: Float = 200
    var score: Float = 0
    
    override init() {
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody!.mass = CGFloat.init(Int.max)
        node.physicsBody!.categoryBitMask = CollisionMask.player.rawValue
        node.physicsBody!.collisionBitMask = CollisionMask.enemy.rawValue
        node.physicsBody!.contactTestBitMask = CollisionMask.enemy.rawValue
        node.physicsBody!.isAffectedByGravity = false
        node.physicsBody!.restitution = 0.0
        node.physicsBody!.setResting(true)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(deltaTime seconds: TimeInterval) {
        node.position = SCNVector3Zero
    }
    
    func takeDamage(_ damage: Float) {
        health -= damage
    }
    
    func addToScore(_ points: Float) {
        score += points
    }
    
    func resetHealth() {
        health = 200
    }
    
    func resetScore() {
        score = 0
    }
}

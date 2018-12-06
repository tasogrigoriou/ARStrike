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
    
    let node: SCNNode
    var anchor: ARAnchor?
    
    override init() {
        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.clear
        let geometry = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0)
        geometry.materials = [material]
        node = SCNNode(geometry: geometry)
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody!.categoryBitMask = CollisionMask.player.rawValue
        node.physicsBody!.collisionBitMask = CollisionMask.enemy.rawValue
        node.physicsBody!.contactTestBitMask = CollisionMask.enemy.rawValue
        node.physicsBody!.isAffectedByGravity = false
        node.physicsBody!.velocity = SCNVector3Zero
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

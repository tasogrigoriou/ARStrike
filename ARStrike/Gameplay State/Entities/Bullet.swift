//
//  Bullet.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 11/17/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

class Bullet: SCNNode {
    static let name: String = NSStringFromClass(Bullet.self)
    
    override init() {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        let bullet = SCNSphere(radius: 0.06)
        bullet.materials = [material]
        
        super.init()
        
        geometry = bullet
        name = Bullet.name
        
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: SCNSphere(radius: 0.033), options: nil))
        physicsBody!.categoryBitMask = CollisionMask.bullet.rawValue
        physicsBody!.contactTestBitMask = CollisionMask.enemy.rawValue
        physicsBody!.collisionBitMask = physicsBody!.contactTestBitMask
        physicsBody!.velocityFactor = SCNVector3(100, 100, 100)
        physicsBody!.isAffectedByGravity = false
        physicsBody!.continuousCollisionDetectionThreshold = 0.001
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var initialPosition: float3 {
        switch UIDevice.current.orientation {
        case .portrait:
            return float3(0.06, 0.1, 1)
        case .landscapeLeft:
            return float3(0.1, -0.03, 1)
        case .landscapeRight:
            return float3(-0.1, 0.03, 1)
        default:
            return float3(0, 0, 0)
        }
    }
    
    func getStartPosition(from node: SCNNode) -> float3 {
        
    }
}

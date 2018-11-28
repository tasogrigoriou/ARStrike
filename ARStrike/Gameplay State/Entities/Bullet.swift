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
        physicsBody!.collisionBitMask = physicsBody!.contactTestBitMask
        physicsBody!.velocityFactor = SCNVector3(25, 25, 25)
        physicsBody!.isAffectedByGravity = false
        physicsBody!.continuousCollisionDetectionThreshold = 0.001
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

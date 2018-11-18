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
        material.diffuse.contents = UIImage(named: "portal_gun_bullet")
        
        let bullet = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 10)
        bullet.materials = [material]
        
        super.init()
        
        geometry = bullet
        name = Bullet.name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

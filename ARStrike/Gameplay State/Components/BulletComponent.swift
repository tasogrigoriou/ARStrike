//
//  BulletComponent.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 11/11/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import Foundation
import GameplayKit

class BulletComponent: GKComponent {
    var restPos: float3
    var currentPos: float3
    var vel: float3
    let bullet: SCNNode
    
    init(bullet: SCNNode) {
        self.bullet = bullet
        restPos = bullet.simdPosition
        currentPos = restPos
        vel = float3(0.0)
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

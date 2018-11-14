//
//  GamePortal.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 11/11/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

class Portal: SCNNode {
    static let name: String = NSStringFromClass(Portal.self)
    
    var anchor: ARAnchor?
    var node = load(fileName: "projectiles_chicken")
    
    var distance: Float = 10.0
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

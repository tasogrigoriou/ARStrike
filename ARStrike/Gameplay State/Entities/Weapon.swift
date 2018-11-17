//
//  GameWeapon.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 11/12/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

class Weapon: SCNNode {
    static let name: String = NSStringFromClass(Weapon.self)
    
    var anchor: ARAnchor?
//    var node = SCNNode.loadSCNAsset(modelFileName: "weapon")
    var node = SCNNode.loadSCNAsset(modelFileName: "portalgun")
    
    // place on bottom right corner of screen (w.r.t. camera)
//    let defaultPosition = SCNVector3(1.3, -6, -8)
    let defaultPosition = SCNVector3(0.5, -5, -10) // for portalgun
    
    let distance: Float = 15.0
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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
    let node = SCNNode.loadSCNAsset(modelFileName: "Rickgun")
    
    let defaultPosition = SCNVector3(1.6, -3.2, -7.5) // position weapon at bottom right of screen (w.r.t. camera)
}

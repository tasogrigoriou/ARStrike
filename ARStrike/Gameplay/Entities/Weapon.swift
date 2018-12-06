//
//  Weapon.swift
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
    let node = SCNNode.loadSCNAsset(modelFileName: "ray_gun7")
    let offsetNode = SCNNode.loadSCNAsset(modelFileName: "ray_gun7") ?? SCNNode()
    
 // position weapon at bottom right of screen (w.r.t. camera)
    var defaultPosition: SCNVector3 {
        if UIDevice.current.orientation.isPortrait {
            return SCNVector3(0.027, -0.04, -0.124)
        } else {
            return SCNVector3(0.04, -0.027, -0.124)
        }
    }
    
    var offsetPosition: SCNVector3 {
        if UIDevice.current.orientation.isPortrait {
            return SCNVector3(0.054, -0.035, -0.124)
        } else {
            return SCNVector3(0.103, -0.021, -0.124)
        }
    }
}

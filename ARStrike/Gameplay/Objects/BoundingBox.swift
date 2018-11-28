//
//  BoundingBox.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 11/26/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

class BoundingBox: SCNNode {
    static let name: String = NSStringFromClass(BoundingBox.self)
    
    var anchor: ARAnchor?
    let node = SCNNode.loadSCNAsset(modelFileName: "bounding_box")
}


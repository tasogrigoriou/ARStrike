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

class GameWeapon: SCNNode {
    static let name: String = "Weapon"
    
    var anchor: ARAnchor?
    var weaponNode = GameWeapon.loadWeapon()
    
    let defaultPosition = SCNVector3(1.25, -6, -8) // place on bottom right corner of screen (w.r.t. camera)
    let distance: Float = 15.0
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func loadWeapon() -> SCNNode {
        let sceneURL = Bundle.main.url(forResource: "gun", withExtension: "scn", subdirectory: "art.scnassets")!
        let referenceNode = SCNReferenceNode(url: sceneURL)!
        referenceNode.load()
        
        return referenceNode
    }
}

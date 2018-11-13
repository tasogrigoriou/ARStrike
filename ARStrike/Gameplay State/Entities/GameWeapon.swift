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
    
    // MARK: - Configuration Properties
    static let name: String = "Weapon"
    
    // MARK: - Properties
    /// The PortalAnchor in the scene
    var anchor: ARAnchor?
    
    var weaponNode = GameWeapon.loadWeapon()
    
    let weaponPosition = SCNVector3(1.25, -6, -8)
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

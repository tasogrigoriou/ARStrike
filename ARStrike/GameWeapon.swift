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
    
    /// The minimum size of the board in meters
    static let minimumScale: Float = 0.3
    
    /// The maximum size of the board in meters
    static let maximumScale: Float = 11.0 // 15x27m @ 10, 1.5m x 2.7m @ 1
    
    // MARK: - Properties
    /// The PortalAnchor in the scene
    var anchor: ARAnchor?
    
    var weaponNode = GameWeapon.loadWeapon()
    
    let weaponPosition = SCNVector3(0, 0, 10)
    let distance: Float = 15.0
    
    /// The level's preferred size.
    /// This is used both to set the aspect ratio and to determine
    /// the default size.
    var preferredSize = CGSize(width: 0.5, height: 0.7)
    
    /// The aspect ratio of the level.
    var aspectRatio: Float { return Float(preferredSize.height / preferredSize.width) }
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        // Set initial game portal scale
        simdScale = float3(GameWeapon.minimumScale)
        
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

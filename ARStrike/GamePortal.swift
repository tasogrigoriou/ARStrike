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

class GamePortal: SCNNode {
    static let name: String = "Portal"
    
    var anchor: ARAnchor?
    var portalNode = GamePortal.loadPortal()
    
    var distance: Float = 10.0
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func loadPortal() -> SCNNode {
        let sceneURL = Bundle.main.url(forResource: "projectiles_chicken", withExtension: "scn", subdirectory: "art.scnassets")!
        let referenceNode = SCNReferenceNode(url: sceneURL)!
        referenceNode.load()
        
        return referenceNode
    }
}

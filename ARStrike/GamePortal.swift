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
    
    // MARK: - Configuration Properties
    /// The minimum size of the board in meters
    static let minimumScale: Float = 0.3
    
    /// The maximum size of the board in meters
    static let maximumScale: Float = 11.0 // 15x27m @ 10, 1.5m x 2.7m @ 1
    
    // MARK: - Properties
    /// The PortalAnchor in the scene
    var anchor: ARAnchor?
    
    var portalNode = GamePortal.loadPortal()
    
    var distance: Float = 7.0
    
    /// The game board's most recent positions.
    private var recentPositions: [float3] = []
    
    /// The game board's most recent rotation angles.
    private var recentRotationAngles: [Float] = []
    
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
        simdScale = float3(GamePortal.minimumScale)
        
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
    
    /// Updates the game portal with the latest hit test result and camera.
    func update(with hitTestResult: ARHitTestResult, camera: ARCamera) {
        updateTransform(with: hitTestResult, camera: camera)
    }
    
    /// Update the transform of the game board with the latest hit test result and camera
    private func updateTransform(with hitTestResult: ARHitTestResult, camera: ARCamera) {
        let position = hitTestResult.worldTransform.translation
        
        // Average using several most recent positions.
        recentPositions.append(position)
        recentPositions = Array(recentPositions.suffix(10))
        
        // Move to average of recent positions to avoid jitter.
        let average = recentPositions.reduce(float3(0), { $0 + $1 }) / Float(recentPositions.count)
        simdPosition = average
        
        // Fall back to camera orientation
        orientToCamera(camera)
        simdScale = float3(GamePortal.minimumScale)
    }
    
    private func orientToCamera(_ camera: ARCamera) {
        rotate(to: camera.eulerAngles.y)
    }
    
    private func rotate(to angle: Float) {
        // Avoid interpolating between angle flips of 180 degrees
        let previouAngle = recentRotationAngles.reduce(0, { $0 + $1 }) / Float(recentRotationAngles.count)
        if abs(angle - previouAngle) > .pi / 2 {
            recentRotationAngles = recentRotationAngles.map { $0.normalizedAngle(forMinimalRotationTo: angle, increment: .pi) }
        }
        
        // Average using several most recent rotation angles.
        recentRotationAngles.append(angle)
        recentRotationAngles = Array(recentRotationAngles.suffix(20))
        
        // Move to average of recent positions to avoid jitter.
        let averageAngle = recentRotationAngles.reduce(0, { $0 + $1 }) / Float(recentRotationAngles.count)
        simdRotation = float4(0, 1, 0, averageAngle)
    }
    
}

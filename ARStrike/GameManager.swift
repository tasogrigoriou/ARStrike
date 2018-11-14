//
//  GameManager.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 11/10/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

/* Abstract:
Responsible for tracking the state of the game: which objects are where, who's in the game, etc.
*/

import Foundation
import SceneKit
import ARKit
import GameplayKit

enum GameEntityType: Int {
    case enemy = 1
    case enemyBullet
    case playerBullet
}

enum GameLevel {
    case one
    case two
    case three
}

class GameManager: NSObject {
    
    var level: GameLevel = .one // default level
    private let sceneView: ARSCNView
    
    private var enemies: Set<GameEnemy> = []
    
    private(set) var isInitialized = false
    
    // Physics
//    private let interactionManager = InteractionManager()
//    private let gameObjectManager = GameObjectManager()
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
        super.init()
        sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    // Initializes all the objects and interactions for the game, and prepares to process user input.
    func start() {
        initializeLevel()
        
//        delegate?.managerDidStartGame()
//        startGameMusicEverywhere()
        
        isInitialized = true
    }
    
    private func initializeLevel() {
      initializeEnemiesForLevel(level)
    }
    
    private func initializeEnemiesForLevel(_ level: GameLevel) {
        
    }
    
    // MARK: update
    // Called from rendering loop once per frame
    func update(timeDelta: TimeInterval) {
        for enemy in enemies {
            enemy.update(deltaTime: timeDelta)
        }
    }
    
    func fireBullets(weaponNode: SCNNode, frame: ARFrame?) {
        guard let currentFrame = frame else { return }
        
        var translation = matrix_identity_float4x4
//        translation.columns.3.xyz = float3(-0.7, 0.15, 0.1)
        translation.columns.3.xyz = weaponNode.simdPosition
        
        let bullet = SCNSphere(radius: 0.05)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.yellow
        
        let bulletNode = SCNNode(geometry: bullet)
        bulletNode.name = "Bullet"
        bulletNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        bulletNode.physicsBody!.categoryBitMask = GameEntityType.playerBullet.rawValue
        bulletNode.physicsBody!.contactTestBitMask = GameEntityType.enemy.rawValue
        bulletNode.physicsBody!.isAffectedByGravity = false
        
//        bulletNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
//        bulletNode.simdTransform = currentFrame.camera.transform + translation
        bulletNode.simdTransform = currentFrame.camera.transform
        
        let forceVector = SCNVector3(bulletNode.worldFront.x * 50, bulletNode.worldFront.y * 50, bulletNode.worldFront.z * 50)
        
        bulletNode.physicsBody?.applyForce(forceVector, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(bulletNode)
    }
    
}

extension GameManager: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("began contact")
//        self.didBeginContact(nodeA: contact.nodeA, nodeB: contact.nodeB,
//                             pos: float3(contact.contactPoint), impulse: contact.collisionImpulse)
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        print("ended contact")
//        self.didCollision(nodeA: contact.nodeA, nodeB: contact.nodeB,
//                          pos: float3(contact.contactPoint), impulse: contact.collisionImpulse)
    }
}

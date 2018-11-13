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
    case bullet = 1
    case enemy = 2
}

class GameManager: NSObject {
    
    let level = 1 // default level
    private let sceneView: ARSCNView
    
    // don't execute any code from SCNView renderer until this is true
    private(set) var isInitialized = false
    
    private let player = GamePlayer()
    private var enemies = Set<GameEnemy>()
    
    // Physics
//    private let interactionManager = InteractionManager()
//    private let gameObjectManager = GameObjectManager()
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
        super.init()
        sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    // Initializes all the objects and interactions for the game, and prepares
    // to process user input.
    func start() {
        // Now we initialize all the game objects and interactions for the game.
        
//        initializeGameObjectPool()
//
//        initializeLevel()
//        initBehaviors()
//
//        // Initialize interactions that add objects to the level
//        initializeInteractions()
//
//        delegate?.managerDidStartGame()
//
//        startGameMusicEverywhere()
        
        isInitialized = true
    }
    
    // MARK: update
    // Called from rendering loop once per frame
    func update(timeDelta: TimeInterval) {
        player.update(deltaTime: timeDelta)
        for enemy in enemies {
            enemy.update(deltaTime: timeDelta)
        }
    }
    
    func fireBullets(weaponNode: SCNNode, frame: ARFrame?) {
        guard let currentFrame = frame else { return }
        
        var translation = matrix_identity_float4x4
//        translation.columns.3.z = -0.3
        
        translation.columns.3.z = -0.7
        translation.columns.3.x = 0.15
        translation.columns.3.y = 0.1
        
//        let box = SCNSphere(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        let bullet = SCNSphere(radius: 0.02)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.yellow
        
        let bulletNode = SCNNode(geometry: bullet)
        bulletNode.name = "Bullet"
        bulletNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        bulletNode.physicsBody!.categoryBitMask = GameEntityType.bullet.rawValue
        bulletNode.physicsBody!.contactTestBitMask = GameEntityType.enemy.rawValue
        bulletNode.physicsBody!.isAffectedByGravity = false
        
        // Calculate bullet initial position within the scene
        let position = weaponNode.convertPosition(weaponNode.position, to: bulletNode)
        bulletNode.position = position
        
        bulletNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
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

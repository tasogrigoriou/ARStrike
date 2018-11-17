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

protocol GameManagerDelegate: class {
    
}

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
    private let scene: SCNScene
    
    private var enemies: Set<Enemy> = []
    
    weak var delegate: GameManagerDelegate?
    
    private(set) var isInitialized = false
    private(set) var isAnimating = false
    
    // Physics
//    private let interactionManager = InteractionManager()
//    private let gameObjectManager = GameObjectManager()
    
    init(scene: SCNScene) {
        self.scene = scene
        super.init()
        self.scene.physicsWorld.contactDelegate = self
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
    
    // Called from rendering loop once per frame
    func update(timeDelta: TimeInterval) {
        for enemy in enemies {
            enemy.update(deltaTime: timeDelta)
        }
    }
    
    func fireBullets(weaponNode: SCNNode, frame: ARFrame?) {
        guard let currentFrame = frame else { return }
        
        var translation = matrix_identity_float4x4
        translation.columns.3.xyz = float3(weaponNode.position.x + 6.0, -weaponNode.position.y - 1, weaponNode.position.z)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        let bullet = SCNSphere(radius: 3.0)
        bullet.materials = [material]
        
        let bulletNode = SCNNode(geometry: bullet)
        bulletNode.name = "Bullet"
        bulletNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        bulletNode.physicsBody!.categoryBitMask = GameEntityType.playerBullet.rawValue
        bulletNode.physicsBody!.contactTestBitMask = GameEntityType.enemy.rawValue | GameEntityType.enemyBullet.rawValue
        bulletNode.physicsBody!.isAffectedByGravity = false
                
        bulletNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
        let velocity: Float = 3000
        let forceVector = SCNVector3(bulletNode.worldFront.x * velocity, bulletNode.worldFront.y * velocity, bulletNode.worldFront.z * velocity)
        
        print(bulletNode.worldFront)
        print()
        print(weaponNode.worldFront)
        
        let oldValue = weaponNode.eulerAngles
        let newValue = SCNVector3Make(oldValue.x, oldValue.y + 0.1, oldValue.z - 0.15) // cock back 
        
        if !isAnimating {
            isAnimating = true
            SCNTransaction.animate(duration: 0.12, animations: {
                            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
                weaponNode.eulerAngles = newValue
            }, completion: {
                SCNTransaction.animate(duration: 0.12, animations: {
                                    SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
                    weaponNode.eulerAngles = oldValue
                    self.isAnimating = false
                })
            })
        }
        
        bulletNode.physicsBody?.applyForce(forceVector, asImpulse: true)
        scene.rootNode.addChildNode(bulletNode)
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

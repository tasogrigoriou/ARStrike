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
    func managerDidStartGame()
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
    private let cameraNode: SCNNode?
    
    private var enemies: Set<Enemy> = []
    
    weak var delegate: GameManagerDelegate?
    
    private(set) var isInitialized = false
    private(set) var isAnimating = false
    
    // Physics
//    private let interactionManager = InteractionManager()
//    private let gameObjectManager = GameObjectManager()
    
    init(sceneView: ARSCNView) {
        self.scene = sceneView.scene
        self.cameraNode = sceneView.pointOfView
        super.init()
        self.scene.physicsWorld.contactDelegate = self
    }
    
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
        let enemy = Enemy()
        if let enemyNode = enemy.node {
            enemyNode.position = SCNVector3(0, 0.8, -0.8)
            scene.rootNode.addChildNode(enemyNode)
        }
        enemies.insert(enemy)
    }
    
    // Called from rendering loop once per frame
    func update(timeDelta: TimeInterval) {
        for enemy in enemies {
            enemy.update(deltaTime: timeDelta)
        }
    }
    
    func fireBullets(weaponNode: SCNNode, frame: ARFrame?) {
        guard let currentFrame = frame else { return }
        
        let bulletNode = Bullet()
        bulletNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        bulletNode.physicsBody!.categoryBitMask = GameEntityType.playerBullet.rawValue
        bulletNode.physicsBody!.contactTestBitMask = GameEntityType.enemy.rawValue | GameEntityType.enemyBullet.rawValue
        bulletNode.physicsBody!.isAffectedByGravity = false
        
        var translation = matrix_identity_float4x4
        translation.columns.3.xyz = float3(weaponNode.position.x + 7.5, -weaponNode.position.y + 3.5, weaponNode.position.z - 0.5)
        bulletNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
        let velocity: Float = 3000
        let forceVector = SCNVector3(bulletNode.worldFront.x * velocity, bulletNode.worldFront.y * velocity, bulletNode.worldFront.z * velocity)
        
        bulletNode.physicsBody!.applyForce(forceVector, asImpulse: true)
        scene.rootNode.addChildNode(bulletNode)
        
        applyRecoilAnimation(node: weaponNode)
    }
    
    private func applyRecoilAnimation(node: SCNNode) {
        let oldAngles = node.eulerAngles
        let newAngles = SCNVector3Make(oldAngles.x - 0.36, oldAngles.y, oldAngles.z)
        
        if !isAnimating {
            isAnimating = true
            SCNTransaction.animate(duration: 0.12, animations: {
                SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
                node.eulerAngles = newAngles
            }, completion: {
                SCNTransaction.animate(duration: 0.12, animations: {
                    SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
                    node.eulerAngles = oldAngles
                    self.isAnimating = false
                })
            })
        }
    }
    
    func addBreathingAnimation(to node: SCNNode?) {
        node?.runAction(breathingAction(), forKey: "breathing")
    }
    
    private func breathingAction() -> SCNAction {
        let moveUp = SCNAction.moveBy(x: 0.03, y: 0.25, z: 0, duration: 1.2)
        moveUp.timingMode = .easeInEaseOut
        let moveDown = SCNAction.moveBy(x: -0.03, y: -0.25, z: 0, duration: 1.2)
        moveDown.timingMode = .easeInEaseOut
        let moveSequence = SCNAction.sequence([moveUp, moveDown])
        return SCNAction.repeatForever(moveSequence)
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

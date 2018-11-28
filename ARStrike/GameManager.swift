//
//  GameManager.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 11/10/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import Foundation
import SceneKit
import ARKit
import GameplayKit

struct CollisionMask: OptionSet {
    let rawValue: Int
    
    static let bullet = CollisionMask(rawValue: 4)
    static let enemy = CollisionMask(rawValue: 8)
}

class GameManager: NSObject {
    
    private let scene: SCNScene

    private let portal = Portal()
    private let weapon = Weapon()
    private let boundingBox = BoundingBox()
    private var enemies: Set<Enemy> = []
    
    var level = 1
    
    weak var view: GameViewable?
    
    private(set) var isInitialized = false
    private(set) var isAnimating = false
    
    init(sceneView: ARSCNView, view: GameViewable? = nil) {
        self.scene = sceneView.scene
        self.view = view
        super.init()
        self.scene.physicsWorld.contactDelegate = self
    }

    func addPortalNode() {
        scene.rootNode.addChildNode(portal.node)
    }

    func addWeaponNode() {
        if let cameraNode = view?.scnView.pointOfView, let weaponNode = weapon.node {
            cameraNode.addChildNode(weaponNode)

            // offset position of our weapon to place it at bottom right corner of screen
            // position is relative to parent node (camera)
            // i.e. vector of (0, 0, 0) implies same position as parent node
            weaponNode.position = weapon.defaultPosition
        }
    }
    
    func addBoundingBoxNode() {
        if let boundingBoxNode = boundingBox.node {
            scene.rootNode.addChildNode(boundingBoxNode)
        }
    }

    func addPortalAnchor() {
        if portal.anchor == nil {
            portal.anchor = ARAnchor(name: Portal.name, transform: portal.node.simdTransform)
            view?.scnView.session.add(anchor: portal.anchor!)
        }
    }

    func addWeaponAnchor() {
        if weapon.anchor == nil, let cameraNode = view?.scnView.pointOfView {
            weapon.anchor = ARAnchor(name: Weapon.name, transform: cameraNode.simdTransform)
            view?.scnView.session.add(anchor: weapon.anchor!)
            addBreathingAnimation(to: weapon.node)
        }
    }
    
    func addBoundingBoxAnchor() {
        if boundingBox.anchor == nil, let view = view {
            boundingBox.anchor = ARAnchor(name: BoundingBox.name, transform: scene.rootNode.simdTransform)
            view.scnView.session.add(anchor: boundingBox.anchor!)
        }
    }
    
    func start() {
        setupLevel()
        
//        delegate?.managerDidStartGame()
//        startGameMusicEverywhere()
        
        isInitialized = true
    }
    
    private func setupLevel() {
        setupEnemies(for: level)
    }
    
    private func setupEnemies(for level: Int) {
        // TODO: modularize this code
        let enemy = Enemy()
        if let enemyNode = enemy.node {
            enemyNode.position = portal.node.worldPosition
            scene.rootNode.addChildNode(enemyNode)
        }
        enemies.insert(enemy)
        
    }
    
    // Called from rendering loop once per frame
    func update(timeDelta: TimeInterval) {
        if enemies.isEmpty {
            advanceToNextLevel()
        }
        for enemy in enemies {
            checkBounds(node: enemy.node)
            enemy.update(deltaTime: timeDelta)
        }
    }
    
    func checkBounds(node: SCNNode?) {
        
    }
    
    func advanceToNextLevel() {
        print("advanced to next level!")
    }

    func updatePortal(with hitTestResult: ARHitTestResult, camera: ARCamera) {
        portal.update(with: hitTestResult, camera: camera)
    }
    
    func updateWeaponNodePosition() {
        weapon.node?.position = weapon.defaultPosition
    }

    func fireBullets() {
        guard let weaponNode = weapon.node, let cameraTransform = view?.cameraTransform else { return }

        let bulletNode = Bullet()
        bulletNode.position = weaponNode.worldPosition
        bulletNode.physicsBody?.categoryBitMask = CollisionMask.bullet.rawValue
        bulletNode.physicsBody?.contactTestBitMask = CollisionMask.enemy.rawValue
        bulletNode.physicsBody?.applyForce(cameraTransform.direction, asImpulse: true)
            
        scene.rootNode.addChildNode(bulletNode)
        
        applyRecoilAnimation(node: weaponNode)
    }
    
    private func applyRecoilAnimation(node: SCNNode) {
        let startAngles = node.eulerAngles
        let endAngles = SCNVector3Make(startAngles.x, startAngles.y - 0.24, startAngles.z)
        
        if !isAnimating {
            isAnimating = true
            SCNTransaction.animate(duration: 0.12, animations: {
                SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
                node.eulerAngles = endAngles
            }, completion: {
                SCNTransaction.animate(duration: 0.12, animations: {
                    SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
                    node.eulerAngles = startAngles
                    self.isAnimating = false
                })
            })
        }
    }
    
    func addBreathingAnimation(to node: SCNNode?) {
        node?.runAction(breathingAction(), forKey: "breathing")
    }
    
    private func breathingAction() -> SCNAction {
        let moveUp = SCNAction.moveBy(x: 0.0005, y: 0.003, z: 0, duration: 1.2)
        moveUp.timingMode = .easeInEaseOut
        let moveDown = SCNAction.moveBy(x: -0.0005, y: -0.003, z: 0, duration: 1.2)
        moveDown.timingMode = .easeInEaseOut
        let moveSequence = SCNAction.sequence([moveUp, moveDown])
        return SCNAction.repeatForever(moveSequence)
    }
}

extension GameManager: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("nodeA = \(contact.nodeA), \nnodeB = \(contact.nodeB), \nbegan contact at point \(contact.contactPoint)\n")
        contact.nodeA.removeFromParentNode()
        contact.nodeB.removeFromParentNode()
//        self.didBeginContact(nodeA: contact.nodeA, nodeB: contact.nodeB,
//                             pos: float3(contact.contactPoint), impulse: contact.collisionImpulse)
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        print("ended contact")
//        self.didCollision(nodeA: contact.nodeA, nodeB: contact.nodeB,
//                          pos: float3(contact.contactPoint), impulse: contact.collisionImpulse)
    }
}

struct CameraTransform {
    let position: SCNVector3
    let direction: SCNVector3
}

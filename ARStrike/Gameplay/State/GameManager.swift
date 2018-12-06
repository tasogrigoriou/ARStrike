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
    static let player = CollisionMask(rawValue: 16)
}

class GameManager: NSObject {
    
    private let scene: SCNScene

    private let portal = Portal()
    private let player = Player()
    private let weapon = Weapon()
    private var enemies: Set<Enemy> = []
    
    private let gameLevel = GameLevel()
    
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
            cameraNode.addChildNode(weapon.offsetNode)

            // offset position of our weapon to place it at bottom right corner of screen
            // position is relative to parent node (camera)
            // i.e. vector of (0, 0, 0) implies same position as parent node
            weaponNode.position = weapon.defaultPosition
            weapon.offsetNode.position = weapon.offsetPosition
            weapon.offsetNode.isHidden = true
        }
    }
    
    func addPlayerNode() {
        if let cameraNode = view?.scnView.pointOfView {
            cameraNode.addChildNode(player.node)
        }
    }
    
    func addAnchors() {
        addPlayerAnchor()
        addWeaponAnchor()
        addPortalAnchor()
    }

    private func addPortalAnchor() {
        if portal.anchor == nil {
            portal.anchor = ARAnchor(name: Portal.name, transform: portal.node.simdTransform)
            view?.scnView.session.add(anchor: portal.anchor!)
        }
    }

    private func addWeaponAnchor() {
        if weapon.anchor == nil, let cameraNode = view?.scnView.pointOfView {
            weapon.anchor = ARAnchor(name: Weapon.name, transform: cameraNode.simdTransform)
            view?.scnView.session.add(anchor: weapon.anchor!)
            addBreathingAnimation(to: weapon.node)
        }
    }
    
    private func addPlayerAnchor() {
        if player.anchor == nil, let cameraNode = view?.scnView.pointOfView {
            player.anchor = ARAnchor(name: Player.name, transform: cameraNode.simdTransform)
            view?.scnView.session.add(anchor: player.anchor!)
        }
    }
    
    func start() {
        addWeaponNode()
        
        setupLevel()
        isInitialized = true
    }
    
    private func setupLevel() {
        enemies = gameLevel.enemiesForLevel()
        
        var pos = 0.0
        for enemy in enemies {
            pos += 0.35
            if let enemyNode = enemy.node {
                enemyNode.position = portal.node.worldPosition
//                let constraint = SCNLookAtConstraint(target: view?.scnView.pointOfView)
//                constraint.isGimbalLockEnabled = true
//                constraint.localFront = enemy.enemyLocalFront
//                enemyNode.constraints = [constraint]
                scene.rootNode.addChildNode(enemyNode)
            }
        }
    }
    
    // Called from rendering loop once per frame
    func update(timeDelta: TimeInterval) {
        if enemies.isEmpty {
            advanceToNextLevel()
        }
        if gameLevel.startAttackingPlayer {
            attackPlayer()
        }
        
        for enemy in enemies {
            enemy.update(deltaTime: timeDelta)
        }
    }
    
    func advanceToNextLevel() {
//        print("advanced to next level!")
    }

    func updatePortal(with hitTestResult: ARHitTestResult, camera: ARCamera) {
        portal.update(with: hitTestResult, camera: camera)
    }
    
    func updateWeaponNodePosition() {
        weapon.node?.position = weapon.defaultPosition
        weapon.offsetNode.position = weapon.offsetPosition
    }
    
    func attackPlayer() {
        if let enemy = enemies.randomElement(), let playerPosition = view?.scnView.pointOfView?.worldPosition {
            enemy.isAttackingPlayer = true
            enemy.node?.runAction(.move(to: playerPosition, duration: enemy.attackTime)) {
                enemy.isAttackingPlayer = false
            }
        }
    }

    func fireBullets() {
        guard let weaponNode = weapon.node, let cameraTransform = view?.cameraTransform else { return }

        let bulletNode = Bullet()
        bulletNode.position = weapon.offsetNode.worldPosition
        bulletNode.physicsBody?.categoryBitMask = CollisionMask.bullet.rawValue
        bulletNode.physicsBody?.contactTestBitMask = CollisionMask.enemy.rawValue
        bulletNode.physicsBody?.collisionBitMask = CollisionMask.enemy.rawValue
        bulletNode.physicsBody?.applyForce(cameraTransform.direction, asImpulse: true)
            
        scene.rootNode.addChildNode(bulletNode)
        
        bulletNode.runAction(.fadeOut(duration: 1.0)) {
            bulletNode.removeFromParentNode()
        }
        
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
    
    private func addBreathingAnimation(to node: SCNNode?) {
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
        print("nodeA = \(contact.nodeA.name ?? "nil"), \nnodeB = \(contact.nodeB.name ?? "nil"), \nbegan contact at point \(contact.contactPoint)\n")
//        contact.nodeA.removeFromParentNode()
        contact.nodeB.removeFromParentNode()
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        print("ended contact")
    }
}

struct CameraTransform {
    let position: SCNVector3
    let direction: SCNVector3
}

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
    private(set) var isGameOver = false
    
    private(set) var contactFinished = true
    
    private let waitTimeBetweenLevels = TimeInterval(2.0)
    
    private let points: Float
    private let damage: Float
    
    init(sceneView: ARSCNView, view: GameViewable? = nil) {
        self.scene = sceneView.scene
        self.view = view
        self.points = GameConstants.defaultPoints * Float(gameLevel.getLevel().rawValue)
        self.damage = GameConstants.defaultEnemyDamage
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
        addPlayerNode()
        
        setupLevel()
        updateGameUI()
        isInitialized = true
    }
    
    private func setupLevel() {
        view?.disableWeapon()
        enemies = gameLevel.enemiesForLevel()
        var waitTime = 0.0
        for enemy in enemies {
            waitTime += 0.2
            if let enemyNode = enemy.node {
                guard let planeNode = portal.node.childNode(withName: "plane", recursively: true) else { return }
                enemyNode.worldPosition = planeNode.worldPosition + SCNVector3(0, 0, -0.05)
                enemyNode.opacity = 0.75
                let constraint = SCNBillboardConstraint()
                enemyNode.constraints = [constraint]
                DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
                    self.scene.rootNode.addChildNode(enemyNode)
                    enemyNode.runAction(.fadeIn(duration: 0.5))
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTimeBetweenLevels) {
            self.view?.enableWeapon()
        }
    }
    
    private func updateGameUI() {
        view?.updateLevelLabel(gameLevel.getLevel().rawValue)
        view?.updatePlayerHealth(CGFloat(player.health))
        view?.updatePlayerScore(player.score)
        view?.showGameUI()
    }
    
    // Called from rendering loop once per frame
    func update(timeDelta: TimeInterval) {
        if enemies.isEmpty {
            advanceToNextLevel()
            return
        }
        if gameLevel.startAttackingPlayer, !isGameOver {
            attackPlayer()
        }
        
        player.update(deltaTime: timeDelta)
        for enemy in enemies {
            enemy.update(deltaTime: timeDelta)
        }
    }
    
    func advanceToNextLevel() {
        isInitialized = false
        gameLevel.setLevel(gameLevel.getLevel().rawValue + 1)
        player.resetHealth()
        Enemy.resetIndexCounter()
        setupLevel()
        updateGameUI()
        isInitialized = true
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
        let moveUp = SCNAction.moveBy(x: 0.0005, y: 0.003, z: 0, duration: 1.2)
        moveUp.timingMode = .easeInEaseOut
        let moveDown = SCNAction.moveBy(x: -0.0005, y: -0.003, z: 0, duration: 1.2)
        moveDown.timingMode = .easeInEaseOut
        let moveSequence = SCNAction.sequence([moveUp, moveDown])
        let breathingAction = SCNAction.repeatForever(moveSequence)
        node?.runAction(breathingAction)
    }
    
    private func addExplosionAnimation(enemyNode: SCNNode, geometryNode: SCNNode?, image: UIImage?) {
        guard let explosion = SCNParticleSystem(named: "Explosion.scnp", inDirectory: "art.scnassets/Explosion/"),
            let geometryNode = geometryNode,
            let image = image else { return }
        contactFinished = false
        
        explosion.emitterShape = geometryNode.geometry
        explosion.particleImage = image
        explosion.birthLocation = .surface
        geometryNode.addParticleSystem(explosion)
        
        enemyNode.runAction(.fadeOut(duration: Double(explosion.particleLifeSpan) - 0.3)) {
            self.removeEnemy(enemyNode: enemyNode)
            self.contactFinished = true
        }
    }
    
    private func removeEnemy(enemyNode: SCNNode) {
        if let enemyToRemove = enemies.first(where: { $0.node?.isEqual(enemyNode) ?? false }) {
            enemies.remove(enemyToRemove)
        }
        enemyNode.removeFromParentNode()
    }
    
    private func endGame() {
        isGameOver = true
        view?.showEndGame(score: player.score, level: gameLevel.getLevel().rawValue)
        print("Game over! Your score is \(player.score) and reached level \(gameLevel.getLevel().rawValue)")
    }
}

extension GameManager: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        guard let nodeAMask = contact.nodeA.physicsBody?.categoryBitMask,
            let nodeBMask = contact.nodeB.physicsBody?.categoryBitMask else { return }
        let masks = nodeAMask | nodeBMask
        
        if masks == CollisionMask([.bullet, .enemy]).rawValue {
            let enemyNode = nodeAMask == CollisionMask.enemy.rawValue ? contact.nodeA : contact.nodeB
            let bulletNode = nodeAMask == CollisionMask.bullet.rawValue ? contact.nodeA : contact.nodeB
            guard let enemy = enemies.first(where: { $0.node?.isEqual(enemyNode) ?? false }) else { return }
            player.addToScore(points)
            view?.updatePlayerScore(player.score)
            addExplosionAnimation(enemyNode: enemyNode, geometryNode: enemy.childNodeWithGeometry, image: enemy.image)
            bulletNode.removeFromParentNode()
        }
        else if masks == CollisionMask([.player, .enemy]).rawValue {
            if !contactFinished { return }
            let enemyNode = nodeAMask == CollisionMask.enemy.rawValue ? contact.nodeA : contact.nodeB
            guard let enemy = enemies.first(where: { $0.node?.isEqual(enemyNode) ?? false }), enemy.isAttackingPlayer else { return }
            player.takeDamage(damage)
            view?.updatePlayerHealth(CGFloat(player.health))
            addExplosionAnimation(enemyNode: enemyNode, geometryNode: enemy.childNodeWithGeometry, image: enemy.image)
            UIDevice.vibrate()
            if player.health <= 0 {
                endGame()
            }
        }
    }
}

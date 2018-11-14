//
//  GameViewController.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 11/9/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import ARKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var mappingStatusLabel: UILabel!
    
    var tapGestureRecognizer: UITapGestureRecognizer?
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    
    var portal = Portal()
    var weapon = Weapon()
    
    var gameManager: GameManager? {
        didSet {
            guard let manager = gameManager else {
                sessionState = .initialSetup
                return
            }
            sessionState = .lookingForSurface
            manager.delegate = self
        }
    }
    
    var sessionState: SessionState = .initialSetup {
        didSet {
            configureView()
            configureARSession()
        }
    }
    
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    var canAdjustBoard: Bool {
        return sessionState == .placingPortal
    }
    
    var attemptingPortalPlacement: Bool {
        return sessionState == .lookingForSurface || sessionState == .placingPortal
    }
    
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createGameManager()
        
        setupGestureRecognizers()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        sessionState = .initialSetup
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
        configureARSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func setupGestureRecognizers() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        
        tapGestureRecognizer!.delegate = self
        longPressGestureRecognizer!.delegate = self
        
        tapGestureRecognizer!.isEnabled = false
        
        longPressGestureRecognizer!.minimumPressDuration = 0.0
        longPressGestureRecognizer!.isEnabled = false
        
        sceneView.addGestureRecognizer(tapGestureRecognizer!)
        sceneView.addGestureRecognizer(longPressGestureRecognizer!)
    }
    
    func configureView() {
        var debugOptions: SCNDebugOptions = []
        
        // fix the scaling of the physics debug view to match the world
        debugOptions.insert(.showPhysicsShapes)

        // show where ARKit is detecting feature points
        debugOptions.insert(ARSCNDebugOptions.showFeaturePoints)

        // see high poly-count and LOD transitions - wireframe overlay
        debugOptions.insert(SCNDebugOptions.showWireframe)

        sceneView.debugOptions = debugOptions

        sceneView.showsStatistics = true
    }
    
    func configureARSession() {
        let configuration = ARWorldTrackingConfiguration()
        let options: ARSession.RunOptions
        
        switch sessionState {
        case .initialSetup, .placingPortal, .setupLevel:
            return
        case .lookingForSurface:
            configuration.planeDetection = [.vertical]
            options = [.resetTracking, .removeExistingAnchors]
            if sceneView.isPlaying {
                return
            }
        case .gameInProgress:
            tapGestureRecognizer?.isEnabled = true
            longPressGestureRecognizer?.isEnabled = true
            return
        }
        
        sceneView.session.run(configuration, options: options)
    }
    
    func updateGamePortal(frame: ARFrame) {
        if sessionState == .setupLevel {
            setupLevel()
            return
        }
        guard attemptingPortalPlacement else { return }
        
        if case .normal = frame.camera.trackingState {
            if let result = sceneView.hitTest(screenCenter, types: [.estimatedVerticalPlane, .existingPlaneUsingExtent]).first {
                guard result.distance > 0.5 || sessionState == .placingPortal else { return }
                sessionState = .placingPortal
            } else {
                sessionState = .lookingForSurface
            }
        }
    }
    
    func setupLevel() {
        guard let gameManager = gameManager, sessionState == .setupLevel else { return }
        
        addWeaponNode()
        addCrosshairNode()
        
        GameClock.setLevelStartTime()
        gameManager.start()
        
        sessionState = .gameInProgress
    }
    
    private func createGameManager() {
        gameManager = GameManager(scene: sceneView.scene)
    }
    
    private func addPortalNode() {
        if let cameraNode = sceneView.pointOfView, let portalNode = portal.node {
            sceneView.scene.rootNode.addChildNode(portalNode)
            portalNode.simdPosition = cameraNode.simdWorldFront * portal.distance
        }
    }
    
    private func addWeaponNode() {
        if let cameraNode = sceneView.pointOfView, let weaponNode = weapon.node {
            cameraNode.addChildNode(weaponNode)
            weaponNode.position = weapon.defaultPosition
        }
    }
    
    private func addCrosshairNode() {
        if let cameraNode = sceneView.pointOfView {
            let image = UIImage(named: "crosshairIMG")
            let crosshairNode = SCNNode(geometry: SCNPlane(width: 1, height: 1))
            crosshairNode.geometry?.firstMaterial?.diffuse.contents = image
            cameraNode.addChildNode(crosshairNode)
            crosshairNode.simdPosition = cameraNode.simdWorldFront * simd_float3(0, 0, -10)
            
        }
    }
    
    private func addPortalAnchor() {
        if portal.anchor == nil {
            portal.anchor = ARAnchor(name: Portal.name, transform: portal.simdTransform)
            sceneView.session.add(anchor: portal.anchor!)
        }
    }
    
    private func addWeaponAnchor() {
        if weapon.anchor == nil, let cameraNode = sceneView.pointOfView {
//            var translation = matrix_identity_float4x4
//            translation.columns.3.z = -15.5
//            let transform = matrix_multiply(cameraNode.simdTransform, translation)
//            weapon.anchor = ARAnchor(name: Weapon.name, transform: transform)
            weapon.anchor = ARAnchor(name: Weapon.name, transform: cameraNode.simdTransform)
            sceneView.session.add(anchor: weapon.anchor!)
        }
    }
    
    private func addCrosshairAnchor() {
        if weapon.anchor == nil, let cameraNode = sceneView.pointOfView {
            let crosshairAnchor = ARAnchor(name: "crosshair", transform: cameraNode.simdTransform)
            sceneView.session.add(anchor: crosshairAnchor)
        }
    }
}

extension GameViewController: GameManagerDelegate {
    
}

extension GameViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if sessionState == .gameInProgress {
            fireBullets()
        } else {
            addPortalAnchor()
            addWeaponAnchor()
            addCrosshairAnchor()
                
            sessionState = .setupLevel
        }
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(fireBullets), userInfo: nil, repeats: true)
        } else if gesture.state == .ended || gesture.state == .cancelled {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc private func fireBullets() {
        if sessionState == .gameInProgress, let weaponNode = weapon.node {
            gameManager?.fireBullets(weaponNode: weaponNode, frame: sceneView.session.currentFrame)
        }
    }
}

extension GameViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let gameManager = gameManager, gameManager.isInitialized {
            GameClock.updateAtTime(time: time)
            gameManager.update(timeDelta: GameClock.deltaTime)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        return anchor == portal.anchor ? portal : nil // Return the portal if we already created an anchor
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let portalNode = portal.node else { return }
        portalNode.removeFromParentNode()
        if let name = anchor.name, name.hasPrefix(Portal.name) {
            node.addChildNode(portalNode)
        }
    }
}

extension GameViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if sessionState == .gameInProgress {
            mappingStatusLabel.text = "FIRE!"
            return
        }
        
        if gameManager != nil {
            updateGamePortal(frame: frame)
        }
        
        switch frame.worldMappingStatus {
        case .notAvailable, .limited:
            tapGestureRecognizer?.isEnabled = false
        case .extending, .mapped:
            addPortalNode()
            tapGestureRecognizer?.isEnabled = true
        }
        mappingStatusLabel.text = frame.worldMappingStatus.description
    }
}

enum SessionState {
    case initialSetup
    case lookingForSurface
    case placingPortal
    case setupLevel
    case gameInProgress
}

extension ARFrame.WorldMappingStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notAvailable:
            return "Tracking unavailable"
        case .limited, .extending:
            return "Point straight ahead to place portal"
        case .mapped:
            return "Tap to place portal"
        }
    }
}

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

protocol GameViewable: class {
    var scnView: ARSCNView { get }
    var cameraTransform: CameraTransform { get }
}

class GameViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var mappingStatusLabel: UILabel!
    @IBOutlet weak var crosshair: UIImageView!
    
    var tapGestureRecognizer: UITapGestureRecognizer?
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    
    var gameManager: GameManager? {
        didSet {
            guard let _ = gameManager else {
                sessionState = .initialSetup
                return
            }
            sessionState = .lookingForSurface
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        gameManager?.updateWeaponNodePosition()
    }
    
    func setupGestureRecognizers() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        
        tapGestureRecognizer!.delegate = self
        longPressGestureRecognizer!.delegate = self
        
        tapGestureRecognizer!.isEnabled = false
        longPressGestureRecognizer!.isEnabled = false
        
        longPressGestureRecognizer!.minimumPressDuration = 0.0
        
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

//        sceneView.debugOptions = debugOptions

//        sceneView.showsStatistics = true
    }
    
    func configureARSession() {
        let configuration = ARWorldTrackingConfiguration()
        let options: ARSession.RunOptions
        
        switch sessionState {
        case .initialSetup, .placingPortal, .setupLevel:
            return
        case .lookingForSurface:
            configuration.planeDetection = [.horizontal]
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
        
        if case .normal = frame.camera.trackingState {
            if let result = sceneView.hitTest(screenCenter, types: [.estimatedHorizontalPlane, .existingPlaneUsingExtent]).first {
                guard result.distance > 0.5 || sessionState == .placingPortal else { return }
                gameManager?.updatePortal(with: result, camera: frame.camera)
                sessionState = .placingPortal
            } else {
                sessionState = .lookingForSurface
            }
            
        }
    }
    
    func setupLevel() {
        guard let gameManager = gameManager, sessionState == .setupLevel else { return }
        
        gameManager.addWeaponNode()
        gameManager.addBoundingBoxNode()
        
        crosshair.alpha = 0.75
        
        GameClock.setLevelStartTime()
        gameManager.start()
        
        sessionState = .gameInProgress
    }
    
    private func createGameManager() {
        gameManager = GameManager(sceneView: sceneView, view: self)
    }
}

extension GameViewController: GameViewable {
    var scnView: ARSCNView {
        return sceneView
    }
    
    var cameraTransform: CameraTransform { // (position, direction)
        if let frame = sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            return CameraTransform(position: pos, direction: dir)
        }
        return CameraTransform(position: SCNVector3Zero, direction: SCNVector3Zero)
    }
}

extension GameViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if sessionState == .gameInProgress {
            fireBullets()
        } else {
            gameManager?.addWeaponAnchor()
            gameManager?.addPortalAnchor()
            gameManager?.addBoundingBoxAnchor()
                
            sessionState = .setupLevel
        }
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            timer = Timer.scheduledTimer(timeInterval: 0.18, target: self, selector: #selector(fireBullets), userInfo: nil, repeats: true)
        } else if gesture.state == .ended || gesture.state == .cancelled {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc private func fireBullets() {
        if sessionState == .gameInProgress {
            gameManager?.fireBullets()
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
            gameManager?.addPortalNode()
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

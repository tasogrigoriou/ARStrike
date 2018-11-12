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
    
    var gamePortal = GamePortal()
    
    var gameManager: GameManager? {
        didSet {
            guard let manager = gameManager else {
                sessionState = .initialSetup
                return
            }
            sessionState = .lookingForSurface
//            manager.delegate = self
        }
    }
    
    var sessionState: SessionState = .initialSetup {
        didSet {
            configureView()
            configureARSession()
            print("sessionState = \(sessionState)")
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
        
        setupGestureRecognizers()
        
        createGameManager()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sessionState = .initialSetup
        sceneView.session.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
        configureARSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's AR session.
        sceneView.session.pause()
    }
    
    func setupGestureRecognizers() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        
        longPressGestureRecognizer!.minimumPressDuration = 0.0
        longPressGestureRecognizer!.isEnabled = false
        
//        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer!.isEnabled = false
        
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
        case .initialSetup:
            return
        case .lookingForSurface:
            // Start tracking the world
            configuration.planeDetection = [.horizontal]
            options = [.resetTracking, .removeExistingAnchors]
            
            // Only reset session if not already running
            if sceneView.isPlaying {
                return
            }
        case .placingPortal:
            // we've found at least one surface, but should keep looking.
            // so no change to the running session
            return
        case .setupLevel:
            // more init
            return
        case .gameInProgress:
            tapGestureRecognizer?.isEnabled = false
            longPressGestureRecognizer?.isEnabled = true
            return
        }
        
        sceneView.session.run(configuration, options: options)
    }
    
    func updateGamePortal(frame: ARFrame) {
        if sessionState == .setupLevel {
            // this will advance the session state
            setupLevel()
            return
        }
        
        // Only automatically update portal when looking for surface or placing board
        guard attemptingPortalPlacement else { return }
        
        // Perform hit testing only when ARKit tracking is in a good state.
        if case .normal = frame.camera.trackingState {

            if let result = sceneView.hitTest(screenCenter, types: [.estimatedHorizontalPlane, .existingPlaneUsingExtent]).first {
                // Ignore results that are too close to the camera when initially placing
                guard result.distance > 0.5 || sessionState == .placingPortal else { return }
                
                sessionState = .placingPortal
                gamePortal.update(with: result, camera: frame.camera)
            } else {
                sessionState = .lookingForSurface
            }
        }
    }
    
    func setupLevel() {
        guard let gameManager = gameManager, sessionState == .setupLevel else { return }
        
        GameClock.setLevelStartTime()
        gameManager.start()
        
        sessionState = .gameInProgress
    }
    
    private func createGameManager() {
        gameManager = GameManager(sceneView: sceneView)
    }
}

extension GameViewController {
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if let _ = sceneView.hitTest(gesture.location(in: sceneView),
                                                 types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane]).first {
            if gamePortal.anchor == nil {
                gamePortal.anchor = ARAnchor(name: "Portal", transform: gamePortal.simdTransform)
                sceneView.session.add(anchor: gamePortal.anchor!)
                
                sessionState = .setupLevel
            }
        }
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
        } else if gesture.state == .ended || gesture.state == .cancelled {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc private func handleTimer() {
        if sessionState == .gameInProgress {
            gameManager?.handleLongPress(with: sceneView.session.currentFrame)
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
        if anchor == gamePortal.anchor {
            DispatchQueue.main.async {
//                self.sessionState = .setupLevel // If portal anchor was added, setup the level.
            }
            
            return gamePortal // We already created a node for the board anchor
        } else {
            return nil 
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        gamePortal.portalNode.removeFromParentNode()
        if let name = anchor.name, name.hasPrefix("Portal") {
            node.addChildNode(gamePortal.portalNode)
        }
    }
}

extension GameViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if sessionState == .gameInProgress { return }
        
        // Update game board placement in physical world
        if gameManager != nil {
            // this is main thread calling into init code
            updateGamePortal(frame: frame)
        }
        
        switch frame.worldMappingStatus {
        case .notAvailable, .limited:
            tapGestureRecognizer?.isEnabled = false
        case .extending:
            tapGestureRecognizer?.isEnabled = false
        case .mapped:
            if let cameraNode = sceneView.pointOfView {
                sceneView.scene.rootNode.addChildNode(gamePortal.portalNode)
                gamePortal.portalNode.simdPosition = cameraNode.simdWorldFront * gamePortal.distance
            }
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
    
    var localizedInstruction: String? {
        switch self {
        case .initialSetup:
            return nil
        case .lookingForSurface:
            return NSLocalizedString("Find a flat surface to place the game.", comment: "")
        case .placingPortal:
            return NSLocalizedString("Scale, rotate or move the portal.", comment: "")
        case .setupLevel:
            return nil
        case .gameInProgress:
            return nil
        }
    }
}

extension ARFrame.WorldMappingStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notAvailable:
            return "Not Available"
        case .limited:
            return "Limited"
        case .extending:
            return "Extending"
        case .mapped:
            return "Mapped"
        }
    }
}

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
    func showGameUI()
    func updateLevelLabel(_ level: Int)
    func updatePlayerScore(_ score: Float)
    func updatePlayerHealth(_ health: CGFloat)
    func disableWeapon()
    func enableWeapon()
    func showDamageScreen()
    func showEndGame(score: Float, level: Int)
}

class GameViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var mappingStatusLabel: UILabel!
    @IBOutlet weak var crosshair: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var animatedScoreLabel: AnimatedLabel!
    @IBOutlet weak var healthImageView: UIImageView!
    @IBOutlet weak var healthBar: GTProgressBar!
    
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
    
    var timer: Timer?
    
    private var isShowingDamageScreen = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
        definesPresentationContext = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createGameManager()

        setupGestureRecognizers()
        hideGameUI()
        
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
    
    private func setupGestureRecognizers() {
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
    
    private func hideGameUI() {
        levelLabel.alpha = 0
        scoreLabel.alpha = 0
        animatedScoreLabel.alpha = 0
        healthBar.alpha = 0
        healthImageView.alpha = 0
        animatedScoreLabel.countingMethod = .linear
    }
    
    func configureView() {
        var debugOptions: SCNDebugOptions = []
        
        // fix the scaling of the physics debug view to match the world
        debugOptions.insert(.showPhysicsShapes)

        // show where ARKit is detecting feature points
        debugOptions.insert(ARSCNDebugOptions.showFeaturePoints)

        // see high poly-count and LOD transitions - wireframe overlay
        debugOptions.insert(SCNDebugOptions.showWireframe)
        
        sceneView.autoenablesDefaultLighting = true

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
    
    func showGameUI() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.6) {
                self.crosshair.alpha = 0.75
                self.levelLabel.alpha = 1
                self.scoreLabel.alpha = 1
                self.animatedScoreLabel.alpha = 1
                self.healthImageView.alpha = 0.9
                self.healthBar.alpha = 0.85
            }
        }
    }
    
    func updateLevelLabel(_ level: Int) {
        DispatchQueue.main.async {
            self.levelLabel.text = "Level: \(level)"
        }
    }
    
    func updatePlayerHealth(_ health: CGFloat) {
        DispatchQueue.main.async {
            self.healthBar.animateTo(progress: health / CGFloat(GameConstants.maxPlayerHealth))
        }
    }
    
    func updatePlayerScore(_ score: Float) {
        DispatchQueue.main.async {
            self.animatedScoreLabel.countFromCurrent(to: score, duration: 1.5)
        }
    }
    
    func disableWeapon() {
        tapGestureRecognizer?.isEnabled = false
        longPressGestureRecognizer?.isEnabled = false
    }
    
    func enableWeapon() {
        tapGestureRecognizer?.isEnabled = true
        longPressGestureRecognizer?.isEnabled = true
    }
    
    func showEndGame(score: Float, level: Int) {
        DispatchQueue.main.async {
            self.present(EndGameViewController(), animated: true)
        }
    }
    
    func showDamageScreen() {
        if isShowingDamageScreen { return }
        isShowingDamageScreen = true
        DispatchQueue.main.async {
            self.present(SplashViewController(), animated: true) { [weak self] in
                self?.dismiss(animated: true) {
                    self?.isShowingDamageScreen = false
                }
            }
        }
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
            gameManager?.addAnchors()
            
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
            mappingStatusLabel.text = ""
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

struct CameraTransform {
    let position: SCNVector3
    let direction: SCNVector3
}

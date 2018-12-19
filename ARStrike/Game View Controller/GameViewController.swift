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
    
    func updateGameMap(with enemies: Set<Enemy>)
    func updateLevelLabel(_ level: Int)
    func updatePlayerScore(_ score: Float)
    func updatePlayerHealth(_ health: Float)
    
    func enableWeapon()
    func disableWeapon()
    
    func showGameUI()
    func showLevel(_ level: Int)
    func showStartLevel()
    func showDamageScreen()
    func showEndGame(with data: EndGameData)
}

class GameViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var mappingStatusLabel: UILabel!
    @IBOutlet weak var crosshair: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var animatedScoreLabel: AnimatedLabel!
    
    @IBOutlet weak var gameMap: Map!
    @IBOutlet weak var healthImageView: UIImageView!
    @IBOutlet weak var healthBar: GTProgressBar!
    
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var damageView: UIView!
    
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
    
    private(set) var isShowingDamageScreen = false
    
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
        
        gameMap.setup()
        
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
        
        animatedScoreLabel.countingMethod = .linear
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
                self.levelLabel.alpha = 1
                self.scoreLabel.alpha = 1
                self.animatedScoreLabel.alpha = 1
                self.healthImageView.alpha = 0.9
                self.healthBar.alpha = 0.85
                self.gameMap.alpha = 1
            }
        }
    }
    
    func updateGameMap(with enemies: Set<Enemy>) {
        DispatchQueue.main.async {
            if let cameraNode = self.sceneView.pointOfView {
                self.gameMap.update(with: cameraNode, enemies: enemies)
            }
        }
    }
    
    func updateLevelLabel(_ level: Int) {
        DispatchQueue.main.async {
            self.levelLabel.text = "Level: \(level)"
        }
    }
    
    func updatePlayerHealth(_ health: Float) {
        DispatchQueue.main.async {
            self.healthBar.animateTo(progress: CGFloat(health) / CGFloat(GameConstants.maxPlayerHealth))
        }
    }
    
    func updatePlayerScore(_ score: Float) {
        DispatchQueue.main.async {
            self.animatedScoreLabel.countFromCurrent(to: score, duration: 1.5)
        }
    }
    
    func disableWeapon() {
        DispatchQueue.main.async {
            self.tapGestureRecognizer?.isEnabled = false
            self.longPressGestureRecognizer?.isEnabled = false
        }
    }
    
    func enableWeapon() {
        DispatchQueue.main.async {
            self.tapGestureRecognizer?.isEnabled = true
            self.longPressGestureRecognizer?.isEnabled = true
        }
    }
    
    func showLevel(_ level: Int) {
        DispatchQueue.main.async {
            self.crosshair.alpha = 0
            self.startLabel.text = "Level \(level)"
            UIView.animate(withDuration: 0.8, delay: 0, options: .transitionCrossDissolve, animations: {
                self.startLabel.alpha = 1
            }, completion: { _ in
                UIView.animate(withDuration: 0.8, delay: 0, options: .transitionCrossDissolve, animations: {
                    self.startLabel.alpha = 0
                }, completion: { _ in
                    
                })
            })
        }
    }
    
    func showStartLevel() {
        DispatchQueue.main.async {
            self.startLabel.text = "Start!"
            UIView.animate(withDuration: 0.7, delay: 0, options: .transitionCrossDissolve, animations: {
                self.startLabel.alpha = 1
            }, completion: { _ in
                UIView.animate(withDuration: 0.7, delay: 0, options: .transitionCrossDissolve, animations: {
                    self.startLabel.alpha = 0
                    self.crosshair.alpha = 0.75
                }, completion: { _ in
                    
                })
            })
        }
    }
    
    func showEndGame(with data: EndGameData) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.crosshair.alpha = 0
            }
            self.present(EndGameViewController(endGameData: data, delegate: self), animated: true)
        }
    }
    
    func showDamageScreen() {
        if isShowingDamageScreen { return }
        isShowingDamageScreen = true
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve, animations: {
                self.damageView.alpha = 1
            }, completion: { _ in
                UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve, animations: {
                    self.damageView.alpha = 0
                }, completion: { _ in
                    self.isShowingDamageScreen = false
                })
            })
        }
    }
}

extension GameViewController: EndGameDelegate {
    func resumeGame() {
        gameManager?.resumeGame()
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

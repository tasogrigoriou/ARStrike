//
//  StartGameViewController.swift
//  ARStrike
//
//  Created by Anastasios Grigoriou on 6/28/19.
//  Copyright © 2019 Taso Grigoriou. All rights reserved.
//

import UIKit
import GameKit
import StoreKit

protocol StartGameDelegate: class {
    func startGame()
    func resumeGame(fromLevel: Int)
    func playThemeMusic()
    func stopThemeMusic()
}

class StartGameViewController: UIViewController, GKGameCenterControllerDelegate {
    @IBOutlet weak var rickAndMortyLabel: UILabel!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var fromLevelLabel: UILabel!
    
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var gameplayButton: UIButton!
    @IBOutlet weak var leaderboardButton: UIButton!
    @IBOutlet weak var loveButton: UIButton!
    
    private var highestLevel: Int {
        return GameLevel.shared.getHighestLevel()
    }
    
    weak var delegate: StartGameDelegate?
    
    var gcEnabled = Bool()
    var gcDefaultLeaderBoard = String()
    
    init(delegate: StartGameDelegate?) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateLocalPlayer()
        setupUI()
    }
    
    private func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = { (ViewController, error) -> Void in
            if ViewController != nil {
                // 1. Show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
            } else if localPlayer.isAuthenticated {
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil {
                        print(error ?? "none")
                    } else {
                        self.gcDefaultLeaderBoard = leaderboardIdentifer!
                    }
                })
                
            } else {
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                print(error ?? "none")
            }
        }
    }
    
    private func setupUI() {
        rickAndMortyLabel.layer.shadowColor = UIColor.black.cgColor
        rickAndMortyLabel.layer.shadowOpacity = 0.5
        rickAndMortyLabel.layer.shadowOffset = .zero
        rickAndMortyLabel.layer.shadowRadius = 0.5
        
        resumeButton.layer.cornerRadius = 6
        resumeButton.layer.borderWidth = 1
        resumeButton.layer.borderColor = resumeButton.backgroundColor?.cgColor
        
        resumeButton.layer.shadowColor = UIColor.black.cgColor
        resumeButton.layer.shadowOpacity = 1
        resumeButton.layer.shadowOffset = .zero
        resumeButton.layer.shadowRadius = 3
        
        startButton.layer.cornerRadius = 6
        startButton.layer.borderWidth = 1
        startButton.layer.borderColor = startButton.backgroundColor?.cgColor
        
        startButton.layer.shadowColor = UIColor.black.cgColor
        startButton.layer.shadowOpacity = 1
        startButton.layer.shadowOffset = .zero
        startButton.layer.shadowRadius = 3
        
        fromLevelLabel.text = "From Level \(highestLevel)"
        fromLevelLabel.layer.shadowColor = UIColor.black.cgColor
        fromLevelLabel.layer.shadowOpacity = 0.5
        fromLevelLabel.layer.shadowOffset = .zero
        fromLevelLabel.layer.shadowRadius = 0.5
        
        if let isAudioEnabled = UserDefaults.standard.value(forKey: "is_audio_enabled") as? Bool {
            if !isAudioEnabled {
                GameConstants.audioEnabled = false
                audioButton.setBackgroundImage(UIImage(named: "no_audio"), for: .normal)
            }
        }
        audioButton.layer.shadowColor = UIColor.black.cgColor
        audioButton.layer.shadowOpacity = 0.1
        audioButton.layer.shadowOffset = .zero
        audioButton.layer.shadowRadius = 0.5
        
        if let isNormalMode = UserDefaults.standard.value(forKey: "is_normal_mode") as? Bool {
            if !isNormalMode {
                GameSettings.gameplayMode = .sitting
                gameplayButton.setBackgroundImage(UIImage(named: "sitting"), for: .normal)
            }
        }
        gameplayButton.layer.shadowColor = UIColor.black.cgColor
        gameplayButton.layer.shadowOpacity = 0.1
        gameplayButton.layer.shadowOffset = .zero
        gameplayButton.layer.shadowRadius = 0.5
        
        leaderboardButton.layer.shadowColor = UIColor.black.cgColor
        leaderboardButton.layer.shadowOpacity = 0.1
        leaderboardButton.layer.shadowOffset = .zero
        leaderboardButton.layer.shadowRadius = 0.5
        
        loveButton.layer.shadowColor = UIColor.black.cgColor
        loveButton.layer.shadowOpacity = 0.1
        loveButton.layer.shadowOffset = .zero
        loveButton.layer.shadowRadius = 0.5
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.startGame()
        }
    }
    
    @IBAction func resumeButtonPressed(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.resumeGame(fromLevel: self.highestLevel)
        }
    }
    
    @IBAction func audioButtonPressed(_ sender: Any) {
        UIView.transition(with: audioButton, duration: 0.3, options: [.curveEaseInOut], animations: {
            GameConstants.audioEnabled.toggle()
            if GameConstants.audioEnabled {
                self.audioButton.setBackgroundImage(UIImage(named: "audio"), for: .normal)
                self.delegate?.playThemeMusic()
            } else {
                self.audioButton.setBackgroundImage(UIImage(named: "no_audio"), for: .normal)
                self.delegate?.stopThemeMusic()
            }
        }) { _ in
            UserDefaults.standard.set(GameConstants.audioEnabled, forKey: "is_audio_enabled")
        }
    }
    
    @IBAction func gameplayButtonPressed(_ sender: Any) {
        UIView.transition(with: gameplayButton, duration: 0.3, options: [.curveEaseInOut], animations: {
            GameSettings.gameplayMode.toggle()
            switch GameSettings.gameplayMode {
            case .normal:
                self.gameplayButton.setBackgroundImage(UIImage(named: "standing"), for: .normal)
            case .sitting:
                self.gameplayButton.setBackgroundImage(UIImage(named: "sitting"), for: .normal)
            }
        }) { _ in
            UserDefaults.standard.set(GameSettings.gameplayMode == .normal, forKey: "is_normal_mode")
        }
    }
    
    @IBAction func leaderboardButtonPressed(_ sender: Any) {
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        present(gcVC, animated: true, completion: nil)
    }
    
    @IBAction func loveButtonPressed(_ sender: Any) {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}


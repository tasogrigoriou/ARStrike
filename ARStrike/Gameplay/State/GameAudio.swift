//
//  GameAudio.swift
//  ARStrike
//
//  Created by Anastasios Grigoriou on 6/29/19.
//  Copyright © 2019 Taso Grigoriou. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class GameAudio {
    public static let shared = GameAudio()
    
    let theme = "rick_and_morty_theme.wav"
    let levelTheme = "rick_and_morty_level_theme.wav"
    let portal = "rick_and_morty_portal.wav"
    let schwifty = "rick_and_morty_schwifty.wav"
    let rayGunFire = "rick_and_morty_ray_gun_shot.wav"
    let pickleRickShot = "rick_and_morty_pickle_rick_shot.wav"
    
    var audioSources: [String: SCNAudioSource] = [:]
    
    var themePlayer: SCNAudioPlayer!
    var levelPlayer: SCNAudioPlayer!
    
    var hasPlayedPortalPlacedSound: Bool = false
    var hasPlayedBulletFiredSound: Bool = false
    var hasPlayedPickleRickShotSound: Bool = false
    
    var isPlayingBulletEnemyCollisionSound: Bool = false
    
    private init() {}
    
    func setupAudio() {
        audioSources[theme] = SCNAudioSource(fileNamed: theme)
        audioSources[theme]!.loops = true
        audioSources[theme]!.volume = 0.2
        audioSources[theme]!.load()
        themePlayer = SCNAudioPlayer(source: audioSources[theme]!)
        
        audioSources[portal] = SCNAudioSource(fileNamed: portal)
        audioSources[portal]!.volume = 0
        audioSources[portal]!.load()
        
        audioSources[levelTheme] = SCNAudioSource(fileNamed: levelTheme)
        audioSources[levelTheme]!.loops = true
        audioSources[levelTheme]!.volume = 0.2
        audioSources[levelTheme]!.load()
        levelPlayer = SCNAudioPlayer(source: audioSources[levelTheme]!)
        
        audioSources[rayGunFire] = SCNAudioSource(fileNamed: rayGunFire)
        audioSources[rayGunFire]!.volume = 0
        audioSources[rayGunFire]!.load()
        
        audioSources[pickleRickShot] = SCNAudioSource(fileNamed: pickleRickShot)
        audioSources[pickleRickShot]!.volume = 0
        audioSources[pickleRickShot]!.load()
    }
    
    func playThemeMusic(scene: SCNScene) {
        guard GameConstants.audioEnabled else { return }
        stopAllMusic(scene: scene)
        themePlayer = SCNAudioPlayer(source: audioSources[theme]!)
        scene.rootNode.addAudioPlayer(themePlayer)
    }
    
    func stopThemeMusic(scene: SCNScene) {
        scene.rootNode.removeAudioPlayer(themePlayer)
    }
    
    func stopAllMusic(scene: SCNScene) {
        scene.rootNode.removeAllAudioPlayers()
    }
    
    func playMusicForLevel(_ level: Int = 0, scene: SCNScene) {
        guard GameConstants.audioEnabled else { return }
        stopAllMusic(scene: scene)
        scene.rootNode.addAudioPlayer(levelPlayer)
    }
    
    func stopMusicForLevel(_ level: Int = 0, scene: SCNScene) {
        scene.rootNode.removeAudioPlayer(levelPlayer)
    }
    
    func playPortalPlacedSound(scene: SCNScene, node: SCNNode) {
        guard GameConstants.audioEnabled else { return }
        if hasPlayedPortalPlacedSound {
            audioSources[portal]!.volume = 1.0
        }
        let soundNode = SCNNode.loadSoundNode()
        soundNode.worldPosition = node.worldPosition
        scene.rootNode.addChildNode(soundNode)
        soundNode.runAction(.playAudio(audioSources[portal]!, waitForCompletion: true)) {
            soundNode.removeFromParentNode()
            self.hasPlayedPortalPlacedSound = true
        }
    }
    
    func playPlayerBreathingSound() {
        guard GameConstants.audioEnabled else { return }
    }
    
    func playBulletFiredSound(scene: SCNScene, bulletNode: SCNNode) {
        guard GameConstants.audioEnabled else { return }
        if hasPlayedBulletFiredSound {
            audioSources[rayGunFire]!.volume = 1.0
        }
        let soundNode = SCNNode.loadSoundNode()
        soundNode.worldPosition = bulletNode.worldPosition
        scene.rootNode.addChildNode(soundNode)
        soundNode.runAction(.playAudio(audioSources[rayGunFire]!, waitForCompletion: true)) {
            soundNode.removeFromParentNode()
            self.hasPlayedBulletFiredSound = true
        }
    }
    
    func playBulletEnemyCollisionSound(scene: SCNScene, node: SCNNode) {
        guard GameConstants.audioEnabled else { return }
        if hasPlayedPickleRickShotSound {
            audioSources[pickleRickShot]!.volume = 1.0
        }
        let soundNode = SCNNode.loadSoundNode()
        soundNode.worldPosition = node.worldPosition
        scene.rootNode.addChildNode(soundNode)
        soundNode.runAction(.playAudio(audioSources[pickleRickShot]!, waitForCompletion: true)) {
            soundNode.removeFromParentNode()
            self.hasPlayedPickleRickShotSound = true
        }
    }
    
    func playEnemyPlayerCollisionSound(scene: SCNScene, node: SCNNode) {
        guard GameConstants.audioEnabled else { return }
        if hasPlayedPickleRickShotSound {
            audioSources[pickleRickShot]!.volume = 1.0
        }
        let soundNode = SCNNode.loadSoundNode()
        soundNode.worldPosition = node.worldPosition
        scene.rootNode.addChildNode(soundNode)
        soundNode.runAction(.playAudio(audioSources[pickleRickShot]!, waitForCompletion: true)) {
            soundNode.removeFromParentNode()
            self.hasPlayedPickleRickShotSound = true
        }
    }
}

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
    
    let theme = "portal_gun_fire.wav"
    let bulletEnemyCollision = "portal_gun_fire.wav"
    
    var audioSources: [String: SCNAudioSource] = [:]
    
    var hasPlayedBulletEnemyCollisionSound: Bool = false
    
    private init() {}
    
    func setupAudio() {
        audioSources[theme] = SCNAudioSource(fileNamed: theme)
        audioSources[theme]!.loops = true
        audioSources[theme]!.load()
        
        audioSources[bulletEnemyCollision] = SCNAudioSource(fileNamed: bulletEnemyCollision)
        audioSources[bulletEnemyCollision]!.volume = 0
        audioSources[bulletEnemyCollision]!.load()
    }
    
    func playThemeMusic(scene: SCNScene) {
        guard GameConstants.audioEnabled else { return }
        
//        scene.rootNode.addAudioPlayer(SCNAudioPlayer(source: audioSources[theme]!))
    }
    
    func stopThemeMusic(scene: SCNScene) {
        scene.rootNode.removeAllAudioPlayers()
    }
    
    func playPlayerBreathingSound() {
        
    }
    
    func playBulletFiredSound() {
        
    }
    
    func playBulletEnemyCollisionSound(scene: SCNScene, node: SCNNode) {
        if hasPlayedBulletEnemyCollisionSound {
            audioSources[bulletEnemyCollision]!.volume = 1.0
        }
        let soundNode = SCNNode.loadSoundNode()
        soundNode.worldPosition = node.worldPosition
        scene.rootNode.addChildNode(soundNode)
        soundNode.runAction(.playAudio(audioSources[bulletEnemyCollision]!, waitForCompletion: true)) {
            soundNode.removeFromParentNode()
            self.hasPlayedBulletEnemyCollisionSound = true
        }
    }
    
    func playEnemyPlayerCollisionSound() {
        
    }
}

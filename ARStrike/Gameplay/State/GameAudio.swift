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
    
    var audioSources: [String: SCNAudioSource] = [:]
    
    private init() {}
    
    func playThemeMusic(sceneView: ARSCNView) {
        let theme = "portal_gun_fire.wav"
        audioSources[theme] = SCNAudioSource(fileNamed: theme)
        audioSources[theme]?.loops = true
        audioSources[theme]?.load()
        if let themeSource = audioSources[theme] {
            sceneView.scene.rootNode.addAudioPlayer(SCNAudioPlayer(source: themeSource))
        }
    }
    
    func setupAudio() {
        let fire = "portal_gun_fire.wav"
        audioSources[fire] = SCNAudioSource(fileNamed: fire)
        audioSources[fire]?.loops = true
        audioSources[fire]?.load()
    }
}

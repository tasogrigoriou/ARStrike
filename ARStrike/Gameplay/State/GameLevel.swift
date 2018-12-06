//
//  GameLevel.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 11/27/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import Foundation

enum Level: Int {
    case one = 1
    case two
    case three
}

struct EnemyComponents {
    let name: String // name of enemy scn file
    let count: Int // number of enemies for a particular level
    let duration: Double // time it takes for enemy to move to new random position
    let cooldownPeriod: Double // time it takes for an enemy to begin attacking the player
    let attackTime: Double // time it takes for an enemy to move from current position to player position and make contact
}

struct StartComponents {
    static let enemy = EnemyComponents(name: "pickle_low", count: 10, duration: 8.0, cooldownPeriod: 10.0, attackTime: 10.0)
}

class GameLevel {
    private var level: Level
    private var enemies: Set<Enemy> = []
    
    var lastAttackTime: CFAbsoluteTime = 0
    
    init(level: Level = .one) {
        self.level = level
    }
    
    func setLevel(_ level: Level) {
        self.level = level
        UserDefaults.standard.set(level, forKey: "furthest_game_level")
    }
    
    func enemiesForLevel() -> Set<Enemy> {
        enemies.removeAll()
        
        if !level.rawValue.isMultipleOfThree() {
            let numberOfEnemies: Int = StartComponents.enemy.count * level.rawValue
            for _ in 0..<numberOfEnemies {
                let enemy = Enemy(
                    modelFileName: StartComponents.enemy.name,
                    duration: StartComponents.enemy.duration / Double(level.rawValue),
                    cooldownPeriod: StartComponents.enemy.cooldownPeriod / Double(level.rawValue),
                    attackTime: StartComponents.enemy.attackTime / Double(level.rawValue)
                )
                enemies.insert(enemy)
            }
        } else {
            // level 3, level 6 returns a boss enemy
            
        }
        
        return enemies
    }
    
    var startAttackingPlayer: Bool {
        let now = CFAbsoluteTimeGetCurrent()
        if now - lastAttackTime > StartComponents.enemy.cooldownPeriod {
            lastAttackTime = now
            return true
        }
        return false
    }
}

extension Int {
    func isMultipleOfThree() -> Bool {
        return self % 3 == 0
    }
    
    func isMultipleOfSix() -> Bool {
        return self % 6 == 0
    }
}

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
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case ten
}

struct EnemyComponents {
    let name: String // name of enemy scn file
    let duration: Double // time it takes for enemy to move to new random position
    let cooldownPeriod: Double // time it takes for an enemy to begin attacking the player
    let attackTime: Double // time it takes for an enemy to move from current position to player position and make contact
}

struct StartComponents {
    static let enemy = EnemyComponents(name: "pickle_low", duration: 8.0, cooldownPeriod: 10.0, attackTime: 10.0)
    static let enemyCount = 10
}

class GameLevel {
    public static let shared = GameLevel()
    
    private var level: Level
    private var enemies: Set<Enemy> = []
    
    var lastAttackTime: CFAbsoluteTime = 0
    var cooldownPeriodForLevel: Double = StartComponents.enemy.cooldownPeriod
    
    private init(level: Level = .one) {
        self.level = level
        setLevel(level.rawValue)
    }
    
    func setLevel(_ rawLevel: Int) {
        if let newlevel = Level(rawValue: rawLevel) {
            self.level = newlevel
            guard let furthestLevel = UserDefaults.standard.value(forKey: "furthest_game_level") as? Int else {
                UserDefaults.standard.set(self.level.rawValue, forKey: "furthest_game_level")
                return
            }
            if newlevel.rawValue > furthestLevel {
                UserDefaults.standard.set(self.level.rawValue, forKey: "furthest_game_level")
            }
        }
    }
    
    func getLevel() -> Int {
        return level.rawValue
    }
    
    func getHighestLevel() -> Int {
        return UserDefaults.standard.value(forKey: "furthest_game_level") as? Int ?? level.rawValue
    }
    
    func enemiesForLevel() -> Set<Enemy> {
        enemies.removeAll()
        
//        if !level.rawValue.isMultipleOfThree() {
            let numberOfEnemies: Int = StartComponents.enemyCount * level.rawValue
            let rawLevel = Double(level.rawValue)
            for _ in 0..<numberOfEnemies {
                let components = EnemyComponents(name: StartComponents.enemy.name,
                                                 duration: StartComponents.enemy.duration / rawLevel,
                                                 cooldownPeriod: StartComponents.enemy.cooldownPeriod / rawLevel,
                                                 attackTime: StartComponents.enemy.attackTime / rawLevel)
                let enemy = Enemy(components: components)
                enemies.insert(enemy)
            }
            cooldownPeriodForLevel = StartComponents.enemy.cooldownPeriod / Double(level.rawValue)
//        }
//        else {
            // level 3, level 6 returns a boss enemy
//
//        }
        
        return enemies
    }
    
    func pointsForLevel() -> Float {
        return GameConstants.defaultPoints * pow(Float(level.rawValue), 2)
    }
    
    var startAttackingPlayer: Bool {
        let now = CFAbsoluteTimeGetCurrent()
        if now - lastAttackTime > cooldownPeriodForLevel {
            lastAttackTime = now
            return true
        }
        return false
    }
}

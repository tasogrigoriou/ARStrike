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
    let speed: Float // speed of enemy when a force is applied at a random direction
    let duration: Float // time it takes for next (random) change of direction
}

struct StartingComponents {
    let name: String = "meeseeks_box"
    let count: Int = 10
    let speed: Float = 0.5
    let duration: Float = 4.0
}

class GameLevel {
    private var level: Level
    private var enemies: Set<Enemy> = []
    
    let startComponents = StartingComponents()
    
    init(level: Level = .one) {
        self.level = level
    }
    
    func setLevel(_ level: Level) {
        self.level = level
        UserDefaults.standard.set(level, forKey: "game_level")
    }
    
    func enemiesForLevel() -> Set<Enemy> {
        enemies.removeAll()
        
        if !level.rawValue.isMultipleOfThree() {
            let numberOfEnemies: Int = startComponents.count * level.rawValue
            for _ in 0..<numberOfEnemies {
                let enemy = Enemy(
                    modelFileName: startComponents.name,
                    speed: startComponents.speed * Float(level.rawValue),
                    duration: startComponents.duration / 2
                )
                enemies.insert(enemy)
            }
        } else {
            // level 3, level 6 returns a boss enemy
            
        }
        
        return enemies
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

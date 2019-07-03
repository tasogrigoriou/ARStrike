//
//  GameProperties.swift
//  ARStrike
//
//  Created by Anastasios Grigoriou on 12/16/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import Foundation

struct GameSettings {
    static var gameplayMode: GameplayMode = .normal
}

enum GameplayMode {
    case normal
    case sitting
    
    mutating func toggle() {
        switch self {
        case .normal: self = .sitting
        case .sitting: self = .normal
        }
    }
}

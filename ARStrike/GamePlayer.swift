//
//  GamePlayer.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 11/11/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

/* GKComponent is the abstract superclass for custom component classes you create when building a game with Entity-Component architecture. In this architecture, an entity is an object relevant to the game, and a component is an object that handles specific aspects of an entity’s behavior in a general way. Because a component’s scope of functionality is limited, you can reuse the same component class for many different kinds of entities.
 You create components by subclassing GKComponent to implement reusable behavior. Then, you build game entities by creating GKEntity objects and using the addComponent(_:) method to attach instances of your custom component classes.
 At runtime, a component-based game needs to dispatch periodic logic—from an update/render loop method such as update(_:) (SpriteKit) or renderer(_:updateAtTime:) (SceneKit), or a CADisplayLink (iOS) or CVDisplayLink (macOS) timer in a custom rendering engine—to each of its components. GameplayKit provides two mechanisms for dispatching updates:
 Per-entity. Call each entity’s update(deltaTime:) method, which will then forward to the update(deltaTime:) method of each component. This option can be quickly implemented in games with a small number of entities and components.
 */


class GamePlayer: GKEntity {
    
}


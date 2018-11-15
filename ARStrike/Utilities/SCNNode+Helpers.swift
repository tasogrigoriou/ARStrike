//
//  SCNNode+Helpers.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 11/13/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import Foundation
import SceneKit

/*
 * Completion blocks run after the animationBlock and let you sequence animation.
 * Since this is more common, an example is shown below:
 *
 *   SCNTransaction.animate(duration: 1.0, animations: {
 *      node.simdWorldTransform = ...    // start at 0, end at 1s
 *   }, completion: {
 *      SCNTransaction.animation(2.0, animations: {
 *          node.simdWorldTransform = ...  // start at 1, end at 3s
 *      }, completion: {
 *          // you can use this to sequence further blocks
 *          foo = true
 *      })
 *   })
 */

extension SCNTransaction {
    static func animate(duration: TimeInterval,
                        animations: (() -> Void)) {
        animate(duration: duration, animations: animations, completion: nil)
    }
    
    static func animate(duration: TimeInterval,
                        animations: (() -> Void),
                        completion: (() -> Void)? = nil) {
        lock(); defer { unlock() }
        begin(); defer { commit() }
        
        animationDuration = duration
        completionBlock = completion
        animations()
    }
}

extension SCNNode {
    static func load(fileName: String) -> SCNNode? {
        guard let sceneURL = Bundle.main.url(forResource: fileName, withExtension: "scn", subdirectory: "art.scnassets") else { return nil }
        guard let referenceNode = SCNReferenceNode(url: sceneURL) else { return nil }
        referenceNode.load()
        return referenceNode
    }
}

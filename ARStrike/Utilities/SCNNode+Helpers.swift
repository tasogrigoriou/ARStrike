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
    static func loadSCNAsset(modelFileName: String) -> SCNNode? {
        let assetPaths = [
            "art.scnassets/",
            "art.scnassets/BoundingBox/",
            "art.scnassets/Camera/",
            "art.scnassets/Chicken/",
            "art.scnassets/Cornvelious/",
            "art.scnassets/HandGun/",
            "art.scnassets/meeseeks-box/",
            "art.scnassets/PickleRick/",
            "art.scnassets/PickleRickLow/",
            "art.scnassets/PixelGun/",
            "art.scnassets/Portal/",
            "art.scnassets/PortalGun/",
            "art.scnassets/PortalGunOther/",
            "art.scnassets/RayGun/",
            "art.scnassets/RickSanchez/",
            "art.scnassets/SenhorPoopy/",
            "art.scnassets/Ship/",
            "art.scnassets/Tank/"
        ]
        
        let assetExtensions = [
            "scn",
            "scnp"
        ]
        
        var nodeRefSearch: SCNReferenceNode?
        for path in assetPaths {
            for ext in assetExtensions {
                if let url = Bundle.main.url(forResource: path + modelFileName, withExtension: ext) {
                    nodeRefSearch = SCNReferenceNode(url: url)
                    if nodeRefSearch != nil { break }
                }
            }
            if nodeRefSearch != nil { break }
        }
        
        guard let nodeRef = nodeRefSearch else { return nil }
        
        // this does the load, default policy is load immediate
        nodeRef.load()
        
        // if geo not nested under a physics shape
        guard let node = nodeRef.childNodes.first else { return nil }
        
        // walk down the scenegraph and update all children
        node.fixMaterials()
        
        return node
    }
}

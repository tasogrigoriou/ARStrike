//
//  SCNNode+Helpers.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 11/13/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    static func load(fileName: String) -> SCNNode? {
        guard let sceneURL = Bundle.main.url(forResource: fileName, withExtension: "scn", subdirectory: "art.scnassets") else { return nil }
        guard let referenceNode = SCNReferenceNode(url: sceneURL) else { return nil }
        referenceNode.load()
        return referenceNode
    }
}

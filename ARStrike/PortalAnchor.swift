//
//  PortalAnchor.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 11/11/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

/*
Abstract:
Custom anchor for saving the portal location in an ARWorldMap.
*/

import ARKit

class PortalAnchor: ARAnchor {
    let size: CGSize
    
    init(transform: float4x4, size: CGSize) {
        self.size = size
        super.init(name: "Portal", transform: transform)
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.size = aDecoder.decodeCGSize(forKey: "size")
        super.init(coder: aDecoder)
    }
    
    // this is guaranteed to be called with something of the same class
    required init(anchor: ARAnchor) {
        let other = anchor as! PortalAnchor
        self.size = other.size
        super.init(anchor: other)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(size, forKey: "size")
    }
}

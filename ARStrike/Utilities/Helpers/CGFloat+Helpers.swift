//
//  CGFloat+Helpers.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 12/18/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {
    func angle(to comparisonPoint: CGPoint) -> CGFloat {
        let originX = comparisonPoint.x - self.x
        let originY = comparisonPoint.y - self.y
        let bearingRadians = atan2f(Float(originY), Float(originX))
        var bearingDegrees = CGFloat(bearingRadians).degrees
        while bearingDegrees < 0 {
            bearingDegrees += 360
        }
        return bearingDegrees
    }
}

extension CGFloat {
    var degrees: CGFloat {
        return self * CGFloat(180.0 / .pi)
    }
}

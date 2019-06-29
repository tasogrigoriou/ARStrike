//
//  Portal.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 11/11/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

class Portal: SCNNode {
    static let name: String = NSStringFromClass(Portal.self)
    
    let node = SCNNode.loadSCNAsset(modelFileName: "rick_and_morty_portal") ?? SCNNode()
    var anchor: ARAnchor?

    static let minimumScale: Float = 0.6
    static let maximumScale: Float = 1.0
    var preferredSize: CGSize = CGSize(width: 0.5, height: 0.5)
    var aspectRatio: Float { return Float(preferredSize.height / preferredSize.width) }
    
    private var recentPositions: [float3] = []
    private var recentRotationAngles: [Float] = []
    
    /// Updates the portal with the latest hit test result and camera.
    func update(with hitTestResult: ARHitTestResult, camera: ARCamera) {
        updateTransform(with: hitTestResult, camera: camera)
    }
    
    private func updateTransform(with hitTestResult: ARHitTestResult, camera: ARCamera) {
        let position = hitTestResult.worldTransform.translation
        
        // Average using several most recent positions.
        recentPositions.append(position)
        recentPositions = Array(recentPositions.suffix(10))
        
        // Move to average of recent positions to avoid jitter.
        let average = recentPositions.reduce(float3(repeating: 0), { $0 + $1 }) / Float(recentPositions.count)
        node.simdPosition = average
        
        // Orient bounds to plane if possible
        if let planeAnchor = hitTestResult.anchor as? ARPlaneAnchor {
            orientToPlane(planeAnchor, camera: camera)
            scaleToPlane(planeAnchor)
        } else {
            // Fall back to camera orientation
            orientToCamera(camera)
            node.simdScale = float3(repeating: Portal.minimumScale)
        }
    }
    
    private func orientToCamera(_ camera: ARCamera) {
        rotate(to: camera.eulerAngles.y)
    }
    
    private func orientToPlane(_ planeAnchor: ARPlaneAnchor, camera: ARCamera) {
        // Get board rotation about y
        node.simdOrientation = simd_quatf(planeAnchor.transform)
        var boardAngle = node.simdEulerAngles.y
        
        // If plane is longer than deep, rotate 90 degrees
        if planeAnchor.extent.x > planeAnchor.extent.z {
            boardAngle += .pi / 2
        }
        
        // Normalize angle to closest 180 degrees to camera angle
        boardAngle = boardAngle.normalizedAngle(forMinimalRotationTo: camera.eulerAngles.y, increment: .pi)
        
        rotate(to: boardAngle)
    }
    
    private func rotate(to angle: Float) {
        // Avoid interpolating between angle flips of 180 degrees
        let previouAngle = recentRotationAngles.reduce(0, { $0 + $1 }) / Float(recentRotationAngles.count)
        if abs(angle - previouAngle) > .pi / 2 {
            recentRotationAngles = recentRotationAngles.map { $0.normalizedAngle(forMinimalRotationTo: angle, increment: .pi) }
        }
        
        // Average using several most recent rotation angles.
        recentRotationAngles.append(angle)
        recentRotationAngles = Array(recentRotationAngles.suffix(20))
        
        // Move to average of recent positions to avoid jitter.
        let averageAngle = recentRotationAngles.reduce(0, { $0 + $1 }) / Float(recentRotationAngles.count)
        node.simdRotation = float4(0, 1, 0, averageAngle)
    }
    
    private func scaleToPlane(_ planeAnchor: ARPlaneAnchor) {
        // Determine if extent should be flipped (plane is 90 degrees rotated)
        let planeXAxis = planeAnchor.transform.columns.0.xyz
        let axisFlipped = abs(dot(planeXAxis, node.simdWorldRight)) < 0.5
        
        // Flip dimensions if necessary
        var planeExtent = planeAnchor.extent
        if axisFlipped {
            planeExtent = vector3(planeExtent.z, 0, planeExtent.x)
        }
        
        // Scale board to the max extent that fits in the plane
        var width = min(planeExtent.x, Portal.maximumScale)
        let depth = min(planeExtent.z, width * aspectRatio)
        width = depth / aspectRatio
        node.simdScale = float3(repeating: width)
        
        // Adjust position of board within plane's bounds
        var planeLocalExtent = float3(width, 0, depth)
        if axisFlipped {
            planeLocalExtent = vector3(planeLocalExtent.z, 0, planeLocalExtent.x)
        }
        adjustPosition(withinPlaneBounds: planeAnchor, extent: planeLocalExtent)
    }
    
    private func adjustPosition(withinPlaneBounds planeAnchor: ARPlaneAnchor, extent: float3) {        
        var positionAdjusted = false
        let worldToPlane = planeAnchor.transform.inverse
        
        // Get current position in the local plane coordinate space
        var planeLocalPosition = (worldToPlane * node.simdTransform.columns.3)
        
        // Compute bounds min and max
        let boardMin = planeLocalPosition.xyz - extent / 2
        let boardMax = planeLocalPosition.xyz + extent / 2
        let planeMin = planeAnchor.center - planeAnchor.extent / 2
        let planeMax = planeAnchor.center + planeAnchor.extent / 2
        
        // Adjust position for x within plane bounds
        if boardMin.x < planeMin.x {
            planeLocalPosition.x += planeMin.x - boardMin.x
            positionAdjusted = true
        } else if boardMax.x > planeMax.x {
            planeLocalPosition.x -= boardMax.x - planeMax.x
            positionAdjusted = true
        }
        
        // Adjust position for z within plane bounds
        if boardMin.z < planeMin.z {
            planeLocalPosition.z += planeMin.z - boardMin.z
            positionAdjusted = true
        } else if boardMax.z > planeMax.z {
            planeLocalPosition.z -= boardMax.z - planeMax.z
            positionAdjusted = true
        }
        
        if positionAdjusted {
            node.simdPosition = (planeAnchor.transform * planeLocalPosition).xyz
        }
    }
}

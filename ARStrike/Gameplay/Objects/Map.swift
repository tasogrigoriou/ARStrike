//
//  Map.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 12/17/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import UIKit
import SceneKit

class Map: UIView {
    
    var playerDot = UIView()
    var enemyDots: [UIView] = []
    
    let dotSize: CGFloat = 4.0
    
    func setup() {
        addBorder()
        addPlayerDot()
    }
    
    private func addBorder() {
        layer.cornerRadius = frame.size.width / 2
        layer.borderColor = UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 0.2).cgColor
        layer.borderWidth = 2.0
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = .zero
        layer.shadowRadius = layer.borderWidth
        layer.masksToBounds = false
    }
    
    private func addPlayerDot() {
        playerDot = UIView(frame: CGRect(x: frame.width / 2 - (dotSize / 2),
                                         y: frame.height / 2 - (dotSize / 2),
                                         width: dotSize,
                                         height: dotSize))
        playerDot.backgroundColor = UIColor(red: 0.59, green: 0.81, blue: 0.30, alpha: 0.95)
        playerDot.center.x = frame.width / 2
        playerDot.center.y = frame.height / 2
        playerDot.layer.cornerRadius = playerDot.frame.size.width / 2
        addSubview(playerDot)
    }
    
    func update(with cameraNode: SCNNode, enemies: Set<Enemy>) {
        enemyDots.forEach { $0.removeFromSuperview() }
        enemyDots.removeAll()
        
        for enemy in enemies {
            guard let enemyNode = enemy.node else { continue }
            
            let relPos = enemyNode.convertPosition(SCNVector3Zero, to: cameraNode)
            let xPos = (frame.size.width / 2) + (CGFloat(relPos.x) * ((frame.size.width / 2) / GameConstants.maxXPosition))
            let zPos = (frame.size.height / 2) + (CGFloat(relPos.z) * ((frame.size.height / 2) / GameConstants.maxZPosition))
            
            // check if position of enemy is in bounds (w.r.t. superview)
            if (xPos > 0 + layer.borderWidth && xPos < frame.size.width - layer.borderWidth) &&
                (zPos > 0 + layer.borderWidth && zPos < frame.size.height - layer.borderWidth) {
                
                let enemyDot = UIView(frame: CGRect(x: xPos, y: zPos, width: dotSize, height: dotSize))
                enemyDot.backgroundColor = enemy.isAttackingPlayer ? .red : .gray
                enemyDot.layer.cornerRadius = enemyDot.frame.size.width / 2
                enemyDots.append(enemyDot)
                
                addSubview(enemyDot)
            }
        }
    }
}
